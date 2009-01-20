module ACPI
  
  class Get
    
    def info
      return `acpi -V`.chop
    end

    def charge(rtype = :string )
      @info = `acpi -V`.chop
      if rtype == :string
      return @info.split("\n")[0].split(",")[1].strip.chop.to_s
      elsif rtype == :int
        return @info.split("\n")[0].split(",")[1].strip.chop.to_i
      end

    end
    
    def temperature
      return `acpi -tB`.chop
      
    end
      
    def ac_status
      return `acpi -aB`.chop
    end
    
  end


end
