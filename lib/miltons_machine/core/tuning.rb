module MiltonsMachine
  module Core

    #
    # == Class: Tuning
    #
    # This class provides methods and services to load and manipulate temperaments both as alternatives to 12 tone
    # equal temperaments scales and micro-tonality.
    #
    # @note tunings can either be specified directly with this class, or can be loaded from an external file.
    # If loaded from an external file, the file must be in a "Scala" format.  For a complete detail on this
    # specification @see http://www.huygens-fokker.org/scala/
    #
    # The site also provides over 4,000 alternative tuning files available for download.  Here is a list:
    #
    # @see http://www.huygens-fokker.org/docs/scalesdir.txt
    #
    # You can download them @see http://www.huygens-fokker.org/docs/scales.zip
    #
    # and then unzip them ()using the -a parameter if you have a mac)
    #
    # @example  OSX
    #   unzip -aa scales.zip
    #

    class Tuning

      # Represents the tuning ratios (as cents) that we need to construct a scale or series.

      attr_accessor :cents

      # The description of the ratios

      attr_accessor :description

      # The path and name of the file to load

      attr_accessor :file_path

      def initialize( file_path = '', cents = [], description = '' )
          @cents       = cents
          @file_path   = file_path
          @description = description
          load(file_path) unless file_path.eql? ''
      end

      # This method will load a file of ratios that represent a specific tuning
      #
      # @param [String] file_path the directory path and name of the file to load
      #

      def load( file_path )
        description_found = false
        length_found      = 0
        number_of_ratios  = 0

        @file_path = file_path
        file = File.new( file_path, 'r')
        file.each_line("\n") do |row|

          # cleanse and prepare

          row.lstrip!
          row.rstrip!
          row.squeeze!(' ')
          next if row[0] == '!'           # ignore comments

          unless description_found        # description is the first non commented line
            @description = row
            description_found = true
            next
          end

          unless number_of_ratios > 0      # total ratios comes next after description is found
            number_of_ratios = row.to_i
            next
          end

          # Cents or fraction then process

          tokens = row.split(' ')
          if tokens[0].include?('.')        # cents
            @cents << tokens[0].to_f
          elsif tokens[0].include?('/')     # if fraction then convert to cents
            parts = tokens[0].split('/')
            # cents <== log(n/d) * (1200/log(2))
            @cents << Math.log10( (parts[0].to_f /  parts[1].to_f) ) * MiltonsMachine::Core::Constants::CENTS_CONVERSION
          end
        end

      end

    end
  end
end
