require_relative "./servers/fiber_web_server"
require_relative "./servers/ractor_web_server"
require_relative "./servers/threaded_web_server"
require_relative "./servers/web_server"

require_relative "./apps/cpu_heavy_app"
require_relative "./apps/file_serving_app"
require_relative "./apps/web_request_app"

# Uncomment an app to run:
# APP = CpuHeavyApp
# APP = FileServingApp
# APP = WebRequestApp

# Uncomment a web server to use:
# SERVER = FiberWebServer
# SERVER = RactorWebServer
# SERVER = ThreadedWebServer
# SERVER = WebServer

SERVER.new(APP.new).start
