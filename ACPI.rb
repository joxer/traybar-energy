module ACPI
  
  class Get
    
    def info
      return `acpi -V`.chop
    end

    def charge(rtype = :string )
      charge = `acpi -b`.chop
      charge =~ /Battery 0\D+(\d+)%.*/
      return -1 if $1 == nil	
      if rtype == :string
      	return $1.to_s
      elsif rtype == :int
        return $1.to_i
      end

    end
    
    def temperature
      temperature=`acpi -tB`.chop
      temperature=~/Thermal 0\D+(\d+.\d+).*/
      return -1 if $1==nil
      return $1
    end
      
    def ac_status
      ac_status=`acpi -aB`.chop
      ac_status=~/AC Adapter 0: (\w+-\w+)/
      return -1 if $1==nil
      return $1
    end
    
  end


end

if __FILE__ == $0
	Test=ACPI::Get.new
	puts "charge in int is: #{Test.charge(:int)}"
	puts "charge in string in: #{Test.charge(:string)}"
	puts "AC-status: #{Test.ac_status}"
	puts "Temperature: #{Test.temperature}"
	puts "info : #{Test.info}"

end
