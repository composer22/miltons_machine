require 'set'

module MiltonsMachine
  module Tools

    #
    # == Class: Generator
    #
    # This tool includes various methods to facilitate the permutation and supply of materials
    # for composition during the course of either composing manually or in real time.
    #
    # @example Permutate set pairs:
    #
    #   working_sets = [[0, 1, 2], [2, 1, 0],
    #                   [3, 4, 5], [5, 4, 3]]
    #
    #   my_generator = MiltonsMachine::Tools::Generator.new
    #
    #   final_results =  my_generator.permutate_set_pairs( working_sets )
    #
    #   final_results.each do |resulting_pair|
    #     puts " #{resulting_pair}"
    #   end
    #
    #   would print out:
    #
    #   [[0, 1, 2], [3, 4, 5]]
    #   [[0, 1, 2], [5, 4, 3]]
    #   [[2, 1, 0], [3, 4, 5]]
    #   [[2, 1, 0], [5, 4, 3]]
    #   [[3, 4, 5], [0, 1, 2]]
    #   [[3, 4, 5], [2, 1, 0]]
    #   [[5, 4, 3], [0, 1, 2]]
    #   [[5, 4, 3], [2, 1, 0]]
    #

    class Generator
      public

      # Constructor
      #
      # @return [Object] a new Generator Object
      #

      def initialize
        # stubbed
      end

      # Given an array of sets as a parameter, this method will permutate combinations
      # and return the results as pairs.  Duplicates between each pair are not returned.
      # (for example [0, 1, 2], [2, 1, 0] are the same and will not be considered a solution)
      #
      # @param [Array] working_sets an array of sets to permutate
      # @return [Array] an array of pairings, less duplicates.
      #

      def permutate_set_pairs( working_sets )
        compare_set1  = Set.new
        compare_set2  = Set.new
        final_results = Array.new

        working_sets.repeated_permutation(2) do |resulting_pair|
          # filter out duplicate prime and retrogrades
          unless compare_set1.replace(resulting_pair[0]) == compare_set2.replace(resulting_pair[1])
              final_results << resulting_pair
          end
        end

        final_results
      end

      # Given a frequency (in hz), this method will compute the harmonic series up to the max range of
      # human hearing (20 kHz) and return an array of values.  Harmonics below human hearing (20 hz) will
      # still be returned.  Array[0] will contain the fundamental frequency.  The index will refer to the
      # partial identifier.
      #
      # @param [Float] fundamental the frequency in hz that we wish to return harmonics on
      # @return [Array] an array of harmonics with Array[0] being the fundamental
      #

      def compute_harmonics( fundamental )
        harmonics = Array.new
        1.upto(20000) do |n|
          result = n * fundamental
          break if result > 20000       # 20 kHz
          harmonics << result
        end
        harmonics
      end

      # Given two frequencies (in hz or kHz), this method will compute the Tartini tones (sum and difference tones)
      #
      # @param [Float] frequency_1 the first frequency that we wish to compute on
      # @param [Float] frequency_2 the second frequency that we wish to compute on
      # @return [Hash] the tartini tones [difference, sum]
      #

      def compute_tartini( frequency_1, frequency_2 )
        difference = frequency_1 > frequency_2 ? frequency_1 - frequency_2 : frequency_2 - frequency_1
        sum = frequency_1 + frequency_2
        { difference: difference, sum: sum }
      end

      # Given a pitch id for a note in equal temperament, will return the frequency in hz.
      #
      # ex: the pitch id for A at 440 hz = 0; for C above it = 3; for E below = -5 etc.
      #
      # @param [Integer] pitch_id the pitch id that we want a frequency for
      # @return [Float] the frequency in hz of the pitch
      #

      def compute_equal_frequency( pitch_id )
        440 * (2 ** ( pitch_id.to_f/12 ) )
      end

      # Given a pitch id, return the MIDI representation of the note
      #
      # ex: the pitch id for A at 440 hz = 0; for C above it = 3; for E below = -5 etc.
      #
      # @param [Integer] pitch_id the pitch id that we want translated to MIDI note id
      # @return [Integer] the MIDI note id
      #

      def convert_to_midi_note( pitch_id )
        69 + pitch_id
      end

      # Given a MIDI note id, translate it to pitch id representation
      #
      # @param [Integer] midi_note_id the MIDI note id that we want translated to pitch id
      # @return [Integer] the pitch id
      #

      def convert_to_pitch_id( midi_note_id )
       midi_note_id - 69
      end

      # Given a pitch id, return the pitch class representation of the note
      #
      # @param [Integer] pitch_id the id of the note we wish translated
      # @return [Integer] the pitch class representation of the note
      #

      def convert_pitch_to_pitch_class( pitch_id )
       (pitch_id + 9) % 12
      end

      # Given a midi id, return the pitch class representation of the note
      #
      # @param [Integer] midi_id the id of the note we wish translated
      # @return [Integer] the pitch class representation of the note
      #

      def convert_midi_to_pitch_class( midi_id )
        convert_pitch_to_pitch_class(convert_to_pitch_id(midi_id))
      end

    end

  end
end
