require 'gtk2'
require 'ACPI'
require 'icon-name'
module Charge
  class Icon < Gtk::StatusIcon
    
    def initialize

      @status = ACPI::Get.new

      @lessthen15=false;
      @lessthen5=false;
      @menu = Lista.new
      
      super()
      
      Thread.new do 
        loop do
          self.set_file("#{IconName::GetIcon.new.get_icon}")
          
          sleep 60
        end
        
      end
      
      signal_connect("popup-menu"){|icon, button, time|
        @menu.show_all
        @menu.popup(nil, nil, button, time)
      }
      self.tip()
    end
    
    #check the battery level

    def check(level)
    
      
      if(level <= 5 and !@lessthen5)
        @lessthen5=true
        dialog("Sotto al 5% di batteria")
        set_blinking(true)
        
      elsif(level <= 15 and !@lessthen15)
        @lessthen15=true
        @lessthen5=false
        set_blinking(false)

        dialog("Rimane meno del 15% di batteria")
      else
        set_blinking(false)
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
  


  class Lista < Gtk::Menu
    
    #menu on popup

    def menugovernor
=begin
        prova a caricare i governors da file, se non ci riesce annuncia la cosa crea il menu con i governors presi dal file ed ad ogni voce del menu associa un evento
=end
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

=begin
        prova a caricare le frequenze da file, se non ci riesce annuncia la cosa crea il menu con le frequenze prese dal file ed ad ogni voce del menu associa un evento
=end

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
=begin
        inizializza il menu settando le voci delle frequenze dei governors e la voce quit
=end

      super()
      
      #governator menu
      
      govmenu = Gtk::ImageMenuItem.new("cpu modes")
      govmenu.image = Gtk::Image.new.set_icon_name("battery")
      govmenu.submenu = menugovernor()
      
      #frequence menu

      freqmenu = Gtk::ImageMenuItem.new("cpu frequencies")
      freqmenu.submenu = menufrequenzies()

      #quit button

      quit=Gtk::MenuItem.new("Quit",true)
      quit.signal_connect("activate"){ Gtk.main_quit}

      #about button

      about = Gtk::MenuItem.new("About us", true)
      about.signal_connect("activate"){ dialog("Traybar-power\nCreated by joxer and Nss\nrealeased on the GNU public license.\nIf you want to join to the develop team send an email to kell.92.k@gmail.com", "Credits")}

      self.append(govmenu)
      self.append(freqmenu)
      self.append(about)
      self.append(quit)
    end
    
    #warning message
    #added obj
    def dialog(message, obj = "WARNING")

      dialog = Gtk::Dialog.new("#{obj}".to_s, nil, Gtk::Dialog::DESTROY_WITH_PARENT,    [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_NONE ])
      dialog.signal_connect('response'){ dialog.destroy }
      dialog.vbox.add(Gtk::Label.new(message))
      dialog.show_all
    end
  end
end


#main program

if `which acpi` != ""
  icon = Charge::Icon.new
  Gtk.main
else
  puts "You haven't installed acpi.\nInstall acpi first and then run this software"

end
