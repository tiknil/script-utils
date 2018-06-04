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
$section_background_color = 'a3fff5'
#definizione lingue gestite
$languages = {
  "it" => {:desc => "Italiano (it)", :index => 1},
  "en" => {:desc => "Inglese (en)", :index => 2},
  "pl" => {:desc => "Polacco (pl)", :index => 3}
}

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
  require 'rubygems'          # dipendenza di rubyXL
  require 'rubyXL'            # per leggere e scrivere i file xlsx
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

  desc "export", "Esporta il file twine in xslx"
  option :input, :required => true, :type => :string, :desc => 'Il file twine da esportare', :aliases => '-i'
  option :output, :default => 'output.xlsx', :type => :string, :desc => 'Il percorso del file Excel di output', :aliases => '-o'
  def export
    #puts "args: #{options[:input]}, #{options[:output]}"

    if !File.exist? options[:input]
      abort "Il file #{options[:input]} non esiste"
    end

    if File.exist? options[:output]
      puts "Il file #{options[:output]} esiste già, sovrascriverlo? (Y/n)"
      confirm = STDIN.gets.chomp
      if confirm != "Y"
        abort
      end
    end

    # Predispongo l'oggetto Excel
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    worksheet.sheet_name = 'Traduzioni'

    #Prima colonna, CHIAVE

    #Headers
    worksheet.add_cell 0,0,"Keys"

    $languages.each do |key, value|
      worksheet.add_cell 0, value[:index] , value[:desc]
      worksheet.change_column_width(value[:index], 100)
    end

    row_index = 0

    #worksheet.change_column_fill(0, 'e7fd55') #Sfondo colonna chiavi
    worksheet.change_row_bold(0, true)
    worksheet.change_row_border(0, :bottom, 'medium')

    spinner = TTY::Spinner.new(":spinner Parsing del file twine in corso... \r", :clear => true, :hide_cursor => true)
    spinner.auto_spin

    File.open(options[:input], 'r') do |file|
      file.each_line do |line|
        trimmed_line = line.strip
        if trimmed_line.start_with? "[["
          #Section
          section = trimmed_line.gsub('[','').gsub(']','')
          row_index += 1
          worksheet.add_cell row_index, 0, section
          worksheet.change_row_fill(row_index, $section_background_color)
          worksheet.sheet_data[row_index][0].change_font_bold(true)
          worksheet.merge_cells(row_index, 0, row_index, 5)
        elsif trimmed_line.start_with? "["
          #Key
          key = trimmed_line.gsub('[','').gsub(']','')
          row_index += 1
          worksheet.add_cell row_index, 0, key
        else
          #Localizations
          elements = trimmed_line.split " = "
          found = false
          if elements.length > 0
            $languages.each do |key, value|
              if elements[0].strip == key
                found = true
                worksheet.add_cell row_index, value[:index], elements[1]
              end
            end
          end

          if !found
            row_index += 1
          end
        end
      end
    end

    # Scrivo il file Excel nel percorso di output
    workbook.write(options[:output])
    spinner.success
  end

  desc "import", "Importa il file xlsx nel file twine"
  option :input, :required => true, :type => :string, :desc => 'Il file xlsx da importare in twine', :aliases => '-i'
  option :output, :default => 'output.txt', :type => :string, :desc => 'Il percorso del file twine di output', :aliases => '-o'
  def import
    puts "args: #{options[:input]}, #{options[:output]}"

    if !File.exist? options[:input]
      abort "Il file #{options[:input]} non esiste"
    end

    if File.exist? options[:output]
      puts "Il file #{options[:output]} esiste già, sovrascriverlo? (Y/n)"
      confirm = STDIN.gets.chomp
      if confirm != "Y"
        abort
      end
    end

    workbook = RubyXL::Parser.parse(options[:input])
    worksheet = workbook.worksheets[0]

    File.open(options[:output], 'w') do |out|
      worksheet.each { |row|
        if row.index_in_collection > 0
          if row.size == 0
            out << "\n"
          elsif row.size == 1
            out << "[[#{row[0].value}]]\n"
          else
            if row[0] == nil || row[0].value == nil || row[0].value.to_s.empty?
              out << "\n"
            else
             out << "\t[#{row[0].value}]\n"
             $languages.each do |key, value|
               if row[value[:index]] != nil
                 out << "\t\t#{key} = #{row[value[:index]].value}\n"
               end
             end
           end
          end
        end
      }
    end
  end

end

#Command line entry point
Twine2xls.start(ARGV)
