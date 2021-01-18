require "app/service"

App::Service.setup( ARGV.shift )

[:TERM, :INT].each do |signal|
  ::Signal.trap( signal ) do
    p signal
    App::Service.shutdown
  end
end

p App::Service.mode
sleep

