require 'socket'

class Daemon

  def self.new_daemon
    gover = []
    gover_hash = Hash.new

    freq = []
    freq_hash = Hash.new

    File.open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors", "r") do |s|
      
      gover = s.readline.split(" ")
      s.close
    end
    
     File.open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies", "r") do |s|
      
      freq = s.readline.split(" ")
      s.close
    end
    
    
    0.upto(gover.length - 1) do |s|
      
      gover_hash[s] = gover[s]
      
    end

    0.upto(freq.length - 1) do |s|

      freq_hash[s] = freq[s]
    end
    
    p freq
    
    File.open("/tmp/daemon.tmp", "w") do |s|
      s.puts Process.pid
      s.close
      
    end
    
    trap(30) do

      
      puts "cpufreq-set -f #{self.command.to_i}"
    end
    
    trap(10) do 
      #define operation here
      
    
      
      puts "cpufreq-set -g #{self.command.to_i}"
    end
    
    sleep 3000
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

  
Daemon.new_daemon

