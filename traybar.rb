#!/usr/bin/env ruby
require 'gtk2'
require 'ACPI'
require 'icon-name'
require 'cpufreq'
require 'menu'

module Charge

	class Icon < Gtk::StatusIcon
	
		def initialize

			@status = ACPI::AcpiData.new
			icon=IconName::GetIcon.new
						
			@nobatterydata=false
			@lessthen15=false;
			@lessthen5=false;
			@menu = Menu.new
	  
			super()
	  
			Thread.new do 
				loop do
					self.set_file("#{icon.get_icon}") 
					sleep 60
				end
			end
	  
			signal_connect("popup-menu") do |icon, button, time|
				@menu.show_all
				@menu.popup(nil, nil, button, time)
			end
			
			self.tip()
			
		end
	
		#check the battery level

		def check(level)
			case level
				when (-1)
					if !@nobatterydata
						@nobatterydata=true
						dialog("Impossibile leggere i dati della batteria")
					end
				when 0..5
					if !@lessthen5
						@lessthen5=true
						@nobatterydata=false
						dialog("Sotto al 5% di batteria")
					end
				when 6..15
					if !@lessthen15
						@lessthen15=true
						@lessthen5=false
						dialog("Rimane meno del 15% di batteria")
					end
				else
					@lessthen5=false
					@nobatterydata=false
					@lessthen15=false
			end
		end
	
		def tip
		
			Thread.new do
				loop do
					check @status.charge(:int)	
					self.tooltip = @status.info
					sleep 60
				end
			end
		end
	
		#dialog to display the warning
		#aggiunto obj, non si sa mai :p
		def dialog(message, obj = "WARNING")
			dialog = Gtk::Dialog.new("#{obj}".to_s, nil, Gtk::Dialog::DESTROY_WITH_PARENT,    [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_NONE ])
			dialog.signal_connect('response'){ dialog.destroy }
			dialog.vbox.add(Gtk::Label.new(message))
			dialog.show_all
		end
	
	end  
end

#main program
if __FILE__==$0
  if (`which acpi` == "")
    puts "You haven't installed acpi.\nInstall acpi first and then run this software"
  else
    begin
      File.new("/tmp/daemon.tmp", "r")
      $pid = File.new("/tmp/daemon.tmp", "r").readlines[0]
      icon = Charge::Icon.new
      Gtk.main
      
    rescue
      puts "run the daemon first"
    end
  end
end
