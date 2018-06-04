#!/usr/bin/env ruby
#
# Questo script serve per automatizzare il processo di aggiornamento delle strighe di traduzione
# Tra file twine ed excel
#
#
# © Tiknil
#

############################################################################################################################################
## FUNCTIONS
############################################################################################################################################

$version = '0.0.1'
$year = '2018'

############################################################################################################################################
## MAIN PROGRAM
############################################################################################################################################

if ARGV.length == 0 || ARGV[0] == 'help'
  puts "Twine2xls\nby Tiknil © #{$year} - Version " + $version + "\n\n"
end

begin
  # Controllo dipendenze
  require 'thor'
  require 'fileutils'         # per varie utilità sul file system
  require 'terminal-table'    # per visualizzare tabelle ASCII nel terminale
  require 'colorize'          # per colorare gli output nel terminale
  require 'tempfile'          # per creare dei file temporanei in memoria
  require 'ruby-progressbar'  # per le progress bar nel terminale
  require 'tty-spinner'       # per gli spinner indefiniti nel terminale
rescue LoadError
  # Installazione dipendenze
  puts "Installazione dipendenze mancanti in corso..."
  # Non posso usare Utils.require_authentication in questo punto
  if Process.uid != 0
    abort "Il comando dev'essere eseguito con privilegi di amministratore (sudo)"
  end
  result = system 'gem install thor & gem install fileutils & gem install terminal-table & gem install colorize & gem install tempfile & gem install ruby-progressbar & gem install tty-spinner'
  if result == true
    puts "Esegui nuovamente il comando richiesto, le dipendenze sono state installate correttamente"
  else
    puts "C'è stato un errore durante l'installazione di alcune dipendenze"
  end
  abort
end


class Twine2xls < Thor

  desc "export", "Esporta il file twine in xsl"
  def export

  end

  desc "import", "Importa il file xls nel file twine"
  def import

  end

end

#Command line entry point
Twine2xls.start(ARGV)
