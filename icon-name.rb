require 'ACPI'

include ACPI

module IconName

  class GetIcon

    def initialize
      
      @status = { 'full' => 'battery', 'low' => 'battery-low', 'caution' => 'battery-caution' }      
    end

    #da rivedere

    def get_icon
      
      return @status['full'] if Get.new.charge(:int) > 15
      
      return @status['low'] if Get.new.charge(:int) < 15 && @info.charge(:int) > 8
      
      return @status['caution'] if Get.new.charge(:int) < 8

    end

  end


end
