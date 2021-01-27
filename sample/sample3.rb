require "app/service"

App::Service.setup( ARGV.shift )

Signal.trap( :INT ) do
  p :INT
  App::Service.shutdown
end

p App::Service.mode
sleep

