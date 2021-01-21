require "app/service" 

App::Service.setup( ARGV.shift )

require "socket"

p port  =  20000
server  =  TCPServer.open( port )

::Signal.trap( :INT ) do
  p  :quit
  server.close
  App::Service.shutdown
end

begin
  while  true
    sock  =  server.accept
    while ( buffer  =  sock.gets )
      sock.puts( buffer.strip )
    end
    sock.close
  end

rescue

end

