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
      @info = `acpi -V`.chop
      return @info.split("\n")[1].split(", ")[1].to_s
    
    end
      
    def AC_status
      @info = `acpi -V`.chop
      return @info.split("\n  ")[2].to_s

    end
    
  end


end
