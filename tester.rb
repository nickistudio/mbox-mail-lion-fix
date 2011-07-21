require 'socket'                # Get sockets from stdlib
require 'net/imap.rb'

#function to get response
def get_response(sock)
    
    buff = ""
    while true
        s = sock.gets("\r\n")
        break unless s
        buff.concat(s)
        if /\{(\d+)\}\r\n/n =~ s
            s = sock.read($1.to_i)
            buff.concat(s)
            else
            break
        end
    end
    return nil if buff.length == 0
    
    return buff#parser.parse(buff)
end

server = TCPServer.open(9142)   # Socket to listen on port 2000
loop {                          # Servers run forever
    Thread.start(server.accept) do |client|
        
        client.puts "* OK [CAPABILITY IMAP4rev1 AUTH=PLAIN] Server ready\r\n"
        
        while true
            print "C: "
            res = get_response(client)
            puts res
            
            code = res[0,5]
            
            while true
                print "S: "
                res = gets 
                client.puts res
                if res[0,5] == code 
                    break
                end
            end
        end
        
        puts "Closing the connection. Bye!"
    client.close                # Disconnect from the client
  end
}
