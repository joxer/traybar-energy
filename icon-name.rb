require 'ACPI'

include ACPI

module IconName

  class GetIcon

    def initialize
      @icons = ["battery-25.svg","battery-25.svg","battery-50.svg","battery-75.svg","battery-full.svg","battery-low-png.svg","battery-emptyalert0.svg","battery-nostatus.svg"] 
    end

    #da rivedere

    def get_icon
	charge=Get.new.charge(:int)
	#only for test, tray ruby icon-name.rb charge
	charge=ARGV.first.to_i if __FILE__ == $0
	basedir="./battery/"
	
	#alert status
	return  basedir+@icons[7] if charge <= 0
	return  basedir+@icons[6] if charge <= 10
	return  basedir+@icons[5] if charge <= 15
      
	return  basedir+@icons[charge/25] 
    end

  end


end


if __FILE__==$0
	Iconclass=IconName::GetIcon.new
	puts Iconclass.get_icon
end