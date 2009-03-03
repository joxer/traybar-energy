

class Daemon

  def self.new_daemon(operation)
    
    trap(30) do 
      #define operation here
      send operation.to_sym
    end
    
    sleep 99999
    
  end

  
end
  
  def a
  puts "b"
  end

Daemon.new_daemon(:a)
