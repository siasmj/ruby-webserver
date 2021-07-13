require_relative "./server/web_server"
require_relative "./apps/file_serving_app"
require_relative "./apps/cpu_heavy_app"
require_relative "./apps/web_request_app"

# Uncomment an app to run:
# APP = CpuHeavyApp
# APP = FileServingApp
# APP = WebRequestApp

SERVER = WebServer

SERVER.new(APP.new).start
