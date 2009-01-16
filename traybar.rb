require 'gtk2'



module Charge
  class Icon < Gtk::StatusIcon
    
    def initialize
      @lessthen15=false;
      @lessthen5=false;
      @menu = Lista.new
      
      super()
      
      self.file = "battery/battery.svg"
      set_icon_name("battery-low")
      
      signal_connect("popup-menu"){|icon, button, time|
        @menu.show_all
        @menu.popup(nil, nil, button, time)
	}
      self.tip()
    end
    
    #check the battery

    def check(level)
      level=level.to_i
      
      if(level <= 5 and !@lessthen5)
        @lessthen5=true;
        dialog("Sotto al 5% di batteria")

        set_icon_name("battery-warning")
        
      elsif(level <= 15 and !@lessthen15)
	@lessthen15=true;
        dialog("Rimane meno del 15% di batteria")

        set_icon_name("battery-low")
      end
    end
    
    def tip
      
      Thread.new do
        loop do
          ch = `acpi -a`.chop
          check(ch.split(/\,/)[1].gsub("%", "")) #percentage of battery
          self.tooltip = ch
          sleep 30
        end
      end
    
    end
    
    #dialog to display the warning

    def dialog(message)
      
      dialog = Gtk::Dialog.new("WARNING".to_s, nil, Gtk::Dialog::DESTROY_WITH_PARENT,    [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_NONE ])

      dialog.signal_connect('response'){ dialog.destroy }

      dialog.vbox.add(Gtk::Label.new(message))
      dialog.show_all
      

    end
    
  end  
  
  class Lista < Gtk::Menu
    
    #menu on popup

    def initialize
      super()

	
	freqsignal=[]
	goversignal=[]
	_goverSubMenu = Gtk::Menu.new
	_freqSubMenu = Gtk::Menu.new
	

	governors = *open('/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors').map { |x| x.rstrip.split }
	for i in governors
		menuvoice = Gtk::MenuItem.new("#{i}", true)
		_goverSubMenu.append(menuvoice)
		menuvoice.set_name(i)
		goversignal.push(menuvoice)
		goversignal.last.signal_connect("activate") do |x|
			puts "sudo cpufreq-set -g #{x.name}"
		    
			#~ `sudo cpufreq-set -g #{x.name}`
		end
	end
	govMenu = Gtk::ImageMenuItem.new("cpu modes")
	govMenu.image = Gtk::Image.new.set_icon_name("battery")
	govMenu.submenu = _goverSubMenu
	
	self.append(govMenu)
	
	
	freq= *open('/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies').map { |x| x.rstrip.split }
	freq.collect! {|x| x.to_i/1000}
	for i in freq
		menuvoice = Gtk::MenuItem.new("#{i}MHz", true)
		_freqSubMenu.append(menuvoice)
		menuvoice.set_name(i.to_s)
		freqsignal.push(menuvoice)
		freqsignal.last.signal_connect("activate") do |x|
		    puts "sudo cpufreq-set -f #{x.name}"
		    #~ `sudo cpufreq-set -f #{x.name}`
		end
	end
	
	freqMenu = Gtk::ImageMenuItem.new("cpu frequence")
	freqMenu.submenu = _freqSubMenu
	self.append(freqMenu)
      
      
    end
    
    #method to set the cpu model

  end
end


#main program

icon = Charge::Icon.new


Gtk.main

