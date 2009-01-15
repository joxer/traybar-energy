require 'ACPI'

a = ACPI::Get.new
puts a.charge
puts a.temperature
puts a.AC_status
