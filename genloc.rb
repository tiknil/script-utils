#!/usr/bin/ruby -w
#
# Questo script serve per automatizzare il processo di aggiornamento delle strighe di traduzione per progetti multipiattaforma
#
# GENerate LOCalizations
#
# © Tiknil
#

require 'optparse'
require 'fileutils'

############################################################################################################################################
## FUNCTIONS
############################################################################################################################################

def gem_available?(name)
   Gem::Specification.find_by_name(name)
rescue Gem::LoadError
   false
rescue
   Gem.available?(name)
end

############################################################################################################################################
## MAIN PROGRAM
############################################################################################################################################

## Definizione delle opzioni che il comando ./genloc.rb può ricevere
options = {:project_name => nil, :project_path => nil, :os => nil}

parser = OptionParser.new do|opts|
	opts.banner = ">>> GENerate LOCalizations: genloc.rb [options]\nAttenzione: per funzionare correttamente per i progetti iOS è necessario che le cartelle di localizzazione (en.lproj, it.lproj, etc) siano già presenti nella cartella /Resources\n\n"

	opts.on('-t', '--twine twine file path', 'Path del file twine') do |twine_file|
		options[:twine_file] = twine_file;
	end

	opts.on('-p', '--path project path', 'Path del progetto (es: ~/App/Android/ProjectName ovvero la cartella che contiene "app" | ~/App/iOS/ProjectName/ProjectName ovvero la cartella che contiene "Resources")') do |project_path|
		options[:project_path] = project_path;
	end

	opts.on('-o', '--os [OS]', [:ios, :android],  'Sistema operativo (ios, android)') do |os|
		options[:os] = os;
	end

	opts.on('-l', '--languages en, it', Array,  'Lista di lingue dei file localizzati (es: en, it, es) - Valido solo per Android. Per iOS vengono controllate le cartelle en.lproj etc. presenti nella cartella "Resources"') do |list|
		options[:languages] = list;
	end

	opts.on('-f', '--force',  'Per forzare l\'esecuzione del comando senza conferma da parte dell\'utente. Utile per utilizzare lo script nei processi di build automatizzati') do |force|
		options[:force] = force;
	end

	opts.on_tail("-h", "--help", "Visualizza help") do
        puts opts
        exit
    end
end
parser.parse!
##

#Controllo argomenti non nulli
if (options[:twine_file] == nil ||
	options[:twine_file] == "")
	abort "Indicare il path del file twine"
end

if (options[:project_path] == nil ||
	options[:project_path] == "")
	abort "Indicare il path del progetto"
end

if (options[:os] == nil ||
	options[:os] == "")
	abort "Indicare il sistema operativo per cui si vogliono creare i file localizzati (valori possibili: 'ios', 'android')"
end

if options[:force] == nil then
	puts "Avvio il processo di generazione delle stringhe localizzate per i seguenti parametri:\n - file twine: " + options[:twine_file].to_s + "\n - path: " + options[:project_path].to_s + "\n - os: " + options[:os].to_s + "\n Confermi (Y/n)?"
	$confirm = STDIN.gets.chomp
else
	$confirm = "Y"
end

if $confirm == "Y"

	if gem_available?('twine')

		if !File.file? options[:twine_file]
			abort "Il file twine non esiste al percorso indicato (" + options[:twine_file] + "). Controllare gli argomenti passati e riprovare"
		end

		case options[:os].to_s
		when "android"
			$dest_path = options[:project_path] + "/app/src/main/res/values/"

			if !File.directory? $dest_path
				abort "Il percorso di destinazione dei file localizzati non esiste (" + $dest_path + "). Controllare gli argomenti passati e riprovare"
			end

			languages_array = ["en", "it"] #Di default creo i file di localizzazione per inglese e italiano
			if options[:languages] != nil
				languages_array = options[:languages]
			end

			languages_array.each do |lang|
				case lang
				when "en"
					puts system("twine generate-string-file " + options[:twine_file] + " " + options[:project_path] + "/app/src/main/res/values/strings.xml")
				else
					$dest_path = options[:project_path] + "/app/src/main/res/values-" + lang + "/"
					if !File.directory? $dest_path
						Dir.mkdir $dest_path #Se non esiste la cartella "values" per la lingua scelta la creo
					end
					puts system("twine generate-string-file " + options[:twine_file] + " " + $dest_path + "strings.xml")
				end
			end

			puts "I file localizzati nelle lingue scelte (se non sono state indicate it ed en) sono stati salvati nelle relative cartelle del progetto Android"
		when "ios"

			$dest_path = options[:project_path] + "/Resources/"

			if !File.directory? $dest_path
				abort "Il percorso di destinazione dei file localizzati non esiste (" + $dest_path + "). Controllare gli argomenti passati"
			end

			puts system("twine generate-all-string-files " + options[:twine_file] + " " + $dest_path)

			puts "I file localizzati sono stati salvati nelle relative cartelle del progetto iOS"
		else
			abort "Il sistema operativo passato non è stato riconosciuto. Puoi usare i valori 'ios' o 'android'"
		end

	else
		abort "Installa prima twine per eseguire il comando genloc: gem install twine"
	end
else
	abort "Alla prossima!"
end
