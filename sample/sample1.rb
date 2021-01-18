require "app/service"

p :echo_console
App::Service.setup( ARGV.shift )

p :echo_redirect
sleep  1

App::Service.shutdown
p :not_reach

