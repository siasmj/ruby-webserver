class FileServingApp
  # Read file from the filesystem based on a path from a request, e.g., "/test.txt"
  def call(env)
    # This is totally unsecure, but good enough for a demo
    # path = Dir.getwd + env['PATH_INFO']
    path = Dir.getwd + "/test.txt"
    if File.exist?(path)
      body = File.read(path)
      [200, { "Content-Type" => "text/html" }, [body]]
    else
      [404, { "Content-Type" => "text/html" }, ['']]
    end
  end
end
