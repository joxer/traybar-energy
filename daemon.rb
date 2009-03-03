require 'socket'

class Daemon

  def self.new_daemon
    gover = []
    gover_hash = Hash.new
    File.open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors", "r") do |s|
      
      gover = s.readline.split(" ")
      s.close
    end
    
    0.upto(gover.length - 1) do |s|

      gover_hash[s] = gover[s]
      
    end

    p gover_hash
    File.open("/tmp/daemon.tmp", "w") do |s|
      s.puts Process.pid
      s.close
      
    end
    
    
    trap(30) do 
      #define operation here
      p gover_hash
      a = self.command
      p gover_hash[a.to_i]
      `cpufreq-set -g #{gover_hash[self.command]}`
    end
    
    sleep 3000
  end

  def self.command
      command = ""
      TCPServer.open("localhost", 5000) do |s|

      s.listen(5)
      client, clien_addr = s.accept
      command = client.gets
      p command
      s.close
      return command
    end
    
      
    
    
    
  end

  
end

  
Daemon.new_daemon

