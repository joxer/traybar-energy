

module CpuFreq

  class Getdata
    
    def self.frequencies
      
      begin
        return *open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies", "r").map{|x| x.rstrip.split}
              
      rescue
        return nil
        raise("frequencies file not avaible")
      end
      
    end
    
    def self.governors
      
      begin 
        return *open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors", "r").map {|x| x.rstrip.split} 
      rescue
        return nil
        raise ("governors file not avaible")
      end
      
    end
    
    
  end
end
if __FILE__ == $0
  p CpuFreq::Getdata.frequencies
  p CpuFreq::Getdata.governors
end
      
      
