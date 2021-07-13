require "open-uri"

class WebRequestApp
  def call(env)
    # URI does not work with Ractor yet https://bugs.ruby-lang.org/issues/17592
    body = URI.open("http://example.com").read
    [200, { "Content-Type" => "text/html" }, [body]]
  end
end
