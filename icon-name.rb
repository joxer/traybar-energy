require 'ACPI'

include ACPI

module IconName

  class GetIcon

    def initialize
      @icons = {"0"=>"battery-25.svg",
			"1"=>"battery-50.svg",
			"2"=>"battery-75.svg",
			"3"=>"battery-full.svg",
			"4"=>"battery-full.svg",
			"low"=>"battery-low-png.svg",
			"alert"=>"battery-emptyalert0.svg",
			"nostatus"=>"battery-nostatus.svg",
			"onac"=>"battery-charge.svg"}	 
    end

    #da rivedere

    def get_icon
	acpi=AcpiData.new
	charge=acpi.charge(:int)
	
	#only for test, tray ruby icon-name.rb charge
	charge=ARGV.first.to_i if __FILE__ == $0
	basedir="./battery/"
	case charge
		when 0..10
			icon=@icons["alert"]
		when 11..15
			icon=@icons["low"]
		when 16..100
			icon=@icons[(charge/25).to_s]
		else
			icon=@icons["onac"] if acpi.on_ac?
			icon=@icons["nostatus"]
		end
	return basedir+icon 
    end

  end


end


if __FILE__==$0
	Iconclass=IconName::GetIcon.new
	puts Iconclass.get_icon
end