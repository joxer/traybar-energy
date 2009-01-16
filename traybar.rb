require 'gtk2'
require 'ACPI'

module Charge
  class Icon < Gtk::StatusIcon
    
    def initialize

      @status = ACPI::Get.new

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
      # level=level.to_i è inutile visto che ho messo l'opzione a intero nel file ACPI
      
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
          check @status.charge(:int)
          self.tooltip = @status.info
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

    def menugovernor
      goversignal=[]
      _goversubmenu = Gtk::Menu.new
     
      begin
         governors = *open('/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors').map { |x| x.rstrip.split }
        for i in governors
          menuvoice = Gtk::MenuItem.new("#{i}", true)
          _goversubmenu.append(menuvoice)
          menuvoice.set_name(i)
          goversignal.push(menuvoice)
          goversignal.last.signal_connect("activate") do |x|
            puts "sudo cpufreq-set -g #{x.name}"
		    
            #~ `sudo cpufreq-set -g #{x.name}`
          end
        end
      rescue
        _goversubmenu.append(Gtk::MenuItem.new("Non disponibile",true))
        dialog "Manca il file per la lettura dei governor disponibili, potrebbe essere\nnecessario caricare il modulo per la gestione dello scaling"
        raise("scaling_available_governors non disponibile")
      ensure
        return _goversubmenu
      end
    end
    
    
    def menufrequenzies
      freqsignal=[]
      _freqsubmenu = Gtk::Menu.new
      begin
        freq= *open('/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies').map { |x| x.rstrip.split }
        freq.collect! {|x| x.to_i/1000}

        for i in freq
          menuvoice = Gtk::MenuItem.new("#{i}MHz", true)
          _freqsubmenu.append(menuvoice)
          menuvoice.set_name(i.to_s)
          freqsignal.push(menuvoice)
          freqsignal.last.signal_connect("activate") do |x|
            puts "sudo cpufreq-set -f #{x.name}"
            #~ `sudo cpufreq-set -f #{x.name}`
          end
        end
      rescue
        _freqsubmenu.append(Gtk::MenuItem.new("non disponibile",true))
         dialog "Manca il file per la lettura delle frequenze disponibili, potrebbe essere\nnecessario caricare il modulo per la gestione dello scaling"
        raise("scaling_available_frequencies non disponibile")
      ensure
        return _freqsubmenu
      end
    end

    def initialize
      super()
      govmenu = Gtk::ImageMenuItem.new("cpu modes")
      govmenu.image = Gtk::Image.new.set_icon_name("battery")
      govmenu.submenu = menugovernor()
      freqmenu = Gtk::ImageMenuItem.new("cpu frequence")
      freqmenu.submenu = menufrequenzies()
      quit=Gtk::MenuItem.new("Quit",true)
      quit.signal_connect("activate") do Gtk.main_quit end
      self.append(govmenu)
      self.append(freqmenu)
      self.append(quit)
    end
    
    #method to set the cpu model
    def dialog(message)

      dialog = Gtk::Dialog.new("WARNING".to_s, nil, Gtk::Dialog::DESTROY_WITH_PARENT,    [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_NONE ])
      dialog.signal_connect('response'){ dialog.destroy }
      dialog.vbox.add(Gtk::Label.new(message))
      dialog.show_all
    end
  end
end


#main program

icon = Charge::Icon.new


Gtk.main

