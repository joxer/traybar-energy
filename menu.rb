class Menu < Gtk::Menu

	#menu on popup

	def menugovernor
=begin
	create a governors menu getting governors from file, if it can't get a warning
=end
		goversignal=[]
		_goversubmenu = Gtk::Menu.new
		governors=@cpufreq.governors
		if governors==nil
			_goversubmenu.append(Gtk::MenuItem.new("Non disponibile",true))
			dialog "Manca il file per la lettura dei governor disponibili, potrebbe essere\nnecessario caricare il modulo per la gestione dello scaling"
		else
			governors.for_each do |g|
				menuvoice = Gtk::MenuItem.new("#{g.to_s}", true)
				_goversubmenu.append(menuvoice)
				menuvoice.set_name(g.to_s)
				goversignal.push(menuvoice)
				goversignal.last.signal_connect("activate") do |x|
					puts "sudo cpufreq-set -g #{x.name}"
					#~ `sudo cpufreq-set -g #{x.name}`
				end
			end
		end
		
		return _goversubmenu
	end


	def menufrequenzies
	
	
=begin
	create a frequencies menu getting frequencies from file, if it can't get a warning
=end

		freqsignal=[]
		_freqsubmenu = Gtk::Menu.new
		frequencies = @cpufreq.frequencies
		if frequencies==nil
			_freqsubmenu.append(Gtk::MenuItem.new("non disponibile",true))
			dialog "Manca il file per la lettura delle frequenze disponibili, potrebbe essere\nnecessario caricare il modulo per la gestione dello scaling"
		else
			frequencies.for_each do |f|
				menuvoice = Gtk::MenuItem.new("#{f.to_s}MHz", true)
				_freqsubmenu.append(menuvoice)
				menuvoice.set_name(f.to_s)
				freqsignal.push(menuvoice)
				freqsignal.last.signal_connect("activate") do |x|
					puts "sudo cpufreq-set -f #{x.name}"
					#~ `sudo cpufreq-set -f #{x.name}`
				end
			end
		end
		return _freqsubmenu
	end

	def initialize
=begin
	intialize the menu setting frequencies and governors
=end

		super()
		@cpufreq= CpuFreq::Getdata.new	
		#governator menu
	  
		govmenu = Gtk::ImageMenuItem.new("cpu modes")
		govmenu.image = Gtk::Image.new.set_icon_name("battery")
		govmenu.submenu = menugovernor()
	  
		#frequence menu

		freqmenu = Gtk::ImageMenuItem.new("cpu frequencies")
		freqmenu.image = Gtk::Image.new.set_icon_name("battery")
		freqmenu.submenu = menufrequenzies()

		#quit button

		quit=Gtk::MenuItem.new("Quit",true)
		quit.signal_connect("activate"){ Gtk.main_quit}

		#about button

		about = Gtk::MenuItem.new("About us", true)
		about.signal_connect("activate"){ dialog("Traybar-power\nCreated by joxer (kell.92.k@gmail.com) and Nss (luca@tulug.it)\nrealeased on the GNU public license.\nIf you want to join to the develop team contact us", "Credits")}

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