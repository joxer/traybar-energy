require 'ACPI'

include ACPI

module IconName

  class GetIcon

    def initialize
      
      @status = { '100' => './battery/battery-full.svg', '75' => './battery/battery-75.svg' , '50' => './battery/battery-50.svg', '25' => './battery/battery-25.svg', '15' => './battery/battery-low-png.svg', 'empty' => './battery/battery-emptyalert0.svg' }      
    end

    #da rivedere

    def get_icon
      
      return @status['100'] if Get.new.charge(:int) > 75 && Get.new.charge(:int) <= 100

      return @status['75'] if Get.new.charge(:int) > 50 && Get.new.charge(:int) <= 75

      return @status['50'] if Get.new.charge(:int) > 25 && Get.new.charge(:int) <= 50
      
      return @status['25'] if Get.new.charge(:int) < 25 && @info.charge(:int) > 10
      return @status['15'] if Get.new.charge(:int) < 15 && @info.charge(:int) > 10
      return @status['empty'] if Get.new.charge(:int) <= 10

    end

  end


end
