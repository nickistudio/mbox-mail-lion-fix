# Mbox Mail for Mac Lion Fix
# Created by Nicholas Workshop

require 'socket'
require 'base64'

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

server = TCPServer.open(9142)
while true
    Thread.start(server.accept) do |client|
        
        mbox = TCPSocket.open("localhost", 9143)
        
        # S: * OK [CAPABILITY IMAP4rev1 AUTH=PLAIN] Server ready
        res = get_response(mbox)
        puts "S: " + res
        client.puts res
        
        # C: A01 AUTHENTICATE PLAIN
        res = get_response(client)
        puts "C: " + res
        code = res.split[0]
        
        # S: +
        res = "+\r\n"
        puts "S: " + res
        client.puts res
        
        # C: XXXXXXXXXXXXXXXXXXXXXXX
        res = get_response(client)
        puts "C: " + res
        secret = res
        
        # Decrypt & login
        command = code + " login" + Base64.decode64(res).gsub(0.chr," ") + "\r\n"
        puts "C: " + command
        mbox.puts command
        
        # S: A01 OK Success / NO Failure
        res = get_response(mbox)
        puts "S: " + res
        client.puts res
        
        # Login finished
        while true
            res = get_response(client)
            puts "C: " + res
            mbox.puts res
            
            code = res.split[0]
            
            while true
                res = get_response(mbox)
                puts "S: " + res
                client.puts res
                
                if res.split[0] == code 
                    break
                end
            end
        end
        
        puts "Closing connection. Bye!"
        client.close
    end
end
