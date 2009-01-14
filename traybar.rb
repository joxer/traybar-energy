require 'gtk2'



module Charge
  class Icon < Gtk::StatusIcon
    
    def initialize
      @menu = Lista.new
      super()
      self.file = "battery/battery.svg"
      set_icon_name("battery-low")
      signal_connect("popup-menu"){|icon, button, time|
        @menu.show_all
        @menu.popup(nil, nil, button, time)
        @menu.powersave
        @menu.performance
        @menu.freq
      }
      self.tip()
    end
    
    #check the battery

    def check(level)
    
      if(level == 15)
        
        dialog("Rimane il 15% di batteria")

        set_icon_name("battery-warning")
        
      elsif(level == 5)
        
        dialog("Rimane il 5% di batteria, attacca la corrente")

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

      freq = [ 800, 1600, 1800, 1900] #frequence of the cpu
      @u = []
      sub = Gtk::Menu.new
      sub2 = Gtk::Menu.new
      @powersave = Gtk::MenuItem.new("powersave", true)
      @performance = Gtk::MenuItem.new("performance", true)
      principal = Gtk::ImageMenuItem.new("cpu modes")
      secondary = Gtk::ImageMenuItem.new("cpu frequence")
      secondary.submenu = sub2
      
      for i in freq
        i = Gtk::MenuItem.new("#{i}MHz", true)
        @u.push i
        
        sub2.append(i)
      end
      principal.submenu = sub
      principal.image = Gtk::Image.new.set_icon_name("battery")
      sub.append(@powersave)
      sub.append(@performance)
      self.append(principal)
      self.append(secondary)
    end
    
    #method to set the cpu modes

    def powersave
        
      @powersave.signal_connect("activate") do
        puts "POWERSAVE MODE SETTED"
        `sudo cpufreq-set -g powersave`
        
      end
    end
    def performance
      
      @performance.signal_connect("activate") do
        puts "PERFORMANCE MODE SETTED"
        `sudo cpufreq-set -g performance`
        
      end
    end
    def freq
     
        end

      end

    end
  end
end


#main program

icon = Charge::Icon.new


Gtk.main
