require "socket"
require "uri"
require_relative "./http_utils/request_parser"
require_relative "./http_utils/http_responder"

class RactorWebServer
  PORT = ENV.fetch("PORT", 3000)
  HOST = ENV.fetch("HOST", "127.0.0.1").freeze
  # Number of incoming connections to keep in a buffer
  SOCKET_READ_BACKLOG = ENV.fetch("TCP_BACKLOG", 12).to_i
  # Number of ractors
  WORKERS_COUNT = ENV.fetch("WORKERS", 4).to_i

  attr_accessor :app

  # Must be a Rack-compatible app
  def initialize(app)
    self.app = app
    # This is hack to make URI parsing work
    # Right now it's broken because this variable is not marked as shareable
    Ractor.make_shareable(URI::RFC3986_PARSER)
    Ractor.make_shareable(URI::DEFAULT_PARSER)
  end

  def start
    # The queue is going to be used to fairly dispatch incoming requests
    # We pass the queue into workers and the first free worker gets the yielded request
    queue = Ractor.new do
      loop do
        conn = Ractor.receive
        Ractor.yield(conn, move: true)
      end
    end

    # Workers determine concurrency
    WORKERS_COUNT.times.map do
      # We need to pass the queue and the server so they are available inside ractor
      Ractor.new(queue, self) do |queue, server|
        loop do
          # this method blocks until the queue yields a connection
          conn = queue.take
          request = RequestParser.call(conn)
          status, headers, body = server.app.call(request)
          HttpResponder.call(conn, status, headers, body)
          # Not rescuing errors not only kills the ractor, but causes random `allocator undefined for Ractor::MovedObject` errors which crashes the whole program
        rescue => e
          puts e.message
        ensure
          conn&.close
        end
      end
    end

    # The listener is going to accept new connections and pass them onto the queue
    # We make it a separate ractor, because `yield` in queue is a blocking operation, we wouldn't be able to accept new connections until all previous were processed
    # And we can't use `send` to send connections to workers because then we would send requests to workers that might be busy
    listener = Ractor.new(queue) do |queue|
      socket = TCPServer.new(HOST, PORT)
      socket.listen(SOCKET_READ_BACKLOG)
      loop do
        conn, _addr_info = socket.accept
        queue.send(conn, move: true)
      end
    end

    Ractor.select(listener)
  end
end
