require 'gtk2'

module Charge
  class Icon < Gtk::StatusIcon
    
    def initialize
      @menu = Lista.new
      super()
      set_icon_name("battery")
      signal_connect("popup-menu"){|icon, button, time|
        @menu.show_all
        @menu.popup(nil, nil, button, time)
        @menu.powersave
        @menu.performance
        
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
      
      #here this code do this sequence first and then the timeout

      ch = `acpi -a`.chop
      remain = ch.split(/\,/)[2] #remaning time and AC state
      if remain == nil
        remain = ch.split(/\,/)[1]
      end
          
      check(ch.split(/\,/)[1].gsub("%", "")) #percentage of battery
      self.tooltip = remain
      
      Gtk.timeout_add(30000) {
        ch = `acpi -a`.chop
        remain = ch.split(/\,/)[2] #remaning time and AC state
        if remain == nil
          remain = ch.split(/\,/)[1]
        end
        check(ch.split(/\,/)[1].gsub("%", "")) #percentage of battery
        self.tooltip = remain
        true
      }

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
      sub = Gtk::Menu.new
      @powersave = Gtk::MenuItem.new("powersave", true)
      @performance = Gtk::MenuItem.new("performance", true)
      principal = Gtk::ImageMenuItem.new("cpu modes")
      principal.submenu = sub
      principal.image = Gtk::Image.new.set_icon_name("battery")
      sub.append(@powersave)
      sub.append(@performance)
      self.append(principal)
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
  end
end

#main program

icon = Charge::Icon.new


Gtk.main
