module CpuFreq

	class Getdata
		attr_reader :frequencies, :governors
		
		def inizialize 
			readgovernors
			readfrequencies
		end
		
		def readgovernors
=begin
	prova a caricare i governors da file, se non ci riesce annuncia la cosa crea il menu con i governors presi dal file ed ad ogni voce del menu associa un evento
=end
			begin
				@governors = *open('/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors').map { |x| x.rstrip.split }
			rescue
				@governors = nil
				raise("scaling_available_governors non disponibile")
			end
		end
		
		
		def readfrequencies

=begin
	prova a caricare le frequenze da file, se non ci riesce annuncia la cosa crea il menu con le frequenze prese dal file ed ad ogni voce del menu associa un evento
=end
			begin
				@frequencies= *open('/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies').map { |x| x.rstrip.split }
				@frequencies.collect! {|x| x.to_i/1000}
			rescue
				@frequencies=nil
				raise("scaling_available_frequencies non disponibile")
			end
		end
	
	end
end

if __FILE__ == $0
	readfreq =CpuFreq::GetData.new
	puts readfreq.frequencies
	puts readfreq.governors
end
	