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


#require 'digest/sha1'
#code = 0.chr + 'nicho29@live.hk' + 0.chr + '12345'
#puts Digest::SHA1.hexdigest(code)


#server = TCPServer.open(9142)   # Socket to listen on port 2000
loop {                          # Servers run forever
    Thread.start(server.accept) do |client|
        
        imap = TCPSocket.open("localhost", 9143)
        
        # * OK [CAPABILITY IMAP4rev1 AUTH=PLAIN] Server ready
        res = get_response(imap)
        client.puts res
        puts "1S: " + res
        
        # 1.721 AUTHENTICATE PLAIN
        res = get_response(client)
        code = res[0,5]
        imap.puts code + " login nicho29@live.hk Joanne26***\r\n"
        #imap.puts res
        puts "1C: " + res
        
        #res = get_response(imap)
        puts get_response(imap)
        
        res = "+\r\n"
        client.puts res
        puts "2S: " + res
        
        print "2C: "
        res = get_response(client)
        puts res
        imap.puts res
        
        print "3S: "
        #puts "adf " + get_response(imap)
        res = code + " OK Success\r\n"
        puts res
        client.puts res
        
        while true
            print "C: "
            res = get_response(client)
            puts res
            imap.puts res
            
            code = res[0,5]
            
            while true
                print "S: "
                res = get_response(imap)
                puts res
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
