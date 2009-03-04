require 'socket'

class Daemon
  
  trap(2) do
    
    `rm /tmp/daemon.tmp`
    exit(0)

  end
  

  trap(9) do
    
    `rm /tmp/daemon.tmp`
    exit(0)
  end

  def self.new_daemon
    File.open("/tmp/daemon.tmp", "w") do |s|
      s.puts Process.pid
      s.close
      
    end
    
  trap(30) do
      
      
      com = self.command.to_s
      if !com.match(";")
        puts "cpufreq-set -g #{com}"
      end
      
    end
    
    trap(10) do 
      #define operation here
      
      com = self.command.to_s
      if !com.match(";")
        puts "cpufreq-set -f #{com}"
      end
      
      
    
    end
    sleep 99999999999999
    



  end


  def self.command
      command = ""
      TCPServer.open("localhost", 5000) do |s|

      s.listen(5)
      client, clien_addr = s.accept
      command = client.gets
      
      s.close
      return command
    end
    
      
    
    
    
  end
  
  
end
if __FILE__ == $0
  Daemon.new_daemon
end
