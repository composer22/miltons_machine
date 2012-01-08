module MiltonsMachine
  module Core

    #
    # == Class: Spectrum
    #
    # This class is provides methods and services to manipulate frequencies in sonic space including
    # teh loading and processing of temperaments and alternative scales related to micro-tonality.
    #

    class Spectrum

      # Represents the spectrum of frequencies that we hear or feel.

      attr_accessor :sonic_space

      def initialize
          @sonic_space = []
      end

      # Given a frequency (in hz), this method will compute the harmonic series up to the max range of
      # human hearing and return an array of values.  Harmonics below human hearing will still be returned.
      # Array[0] will contain the fundamental frequency.  The index will refer to the partial identifier.
      #
      # @param [Float] fundamental the frequency in hz that we wish to return harmonics on
      # @return [Array] an array of harmonics in hz with Array[0] being the fundamental
      #

      def self.compute_harmonics( fundamental )
        harmonics = []
        1.upto(MiltonsMachine::Core::Constants::MAX_HUMAN_HEARING) do |n|
          result = n.to_f * fundamental.to_f
          break if result > MiltonsMachine::Core::Constants::MAX_HUMAN_HEARING
          harmonics << result
        end
        harmonics
      end

      # Given a frequency (in hz), this method will compute the harmonic series up to the max range of
      # human hearing and return an array of values.  Harmonics below human hearing will still be returned.
      # Array[0] will contain the fundamental frequency.  The index will refer to the partial identifier.
      #
      # @param [Float] fundamental the frequency in hz that we wish to return harmonics on
      # @return [Array] an array of harmonics in hz with Array[0] being the fundamental
      #

      def self.compute_subharmonics( fundamental )
        harmonics = []
        1.upto(MiltonsMachine::Core::Constants::MAX_HUMAN_HEARING) do |n|
          result = fundamental.to_f / n.to_f
          break if result < MiltonsMachine::Core::Constants::MIN_HUMAN_HEARING
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

      def self.compute_tartini( frequency_1, frequency_2 )
        difference = frequency_1 > frequency_2 ? frequency_1 - frequency_2 : frequency_2 - frequency_1
        sum = frequency_1 + frequency_2
        { difference: difference, sum: sum }
      end

      # Given a fundamental frequency, this routine will calculate the frequency at a requested octave
      #
      # @param [Float] fundamental the starting frequency of the octave we wish to compute
      # @param [Integer] octave_number which octave higher to calculate 0 = unison; 1 = 1 octave; 2 = 2 octaves etc.
      # @return [Float] the frequency of the higher octave
      # TODO Test

      def self.compute_octave( fundamental, octave_number )
        fundamental * ( 2 ** octave_number )
      end

      # Given a pitch id for a note in equal temperament, will return the frequency in hz.
      #
      # ex: the pitch id for A at 440 hz = 0; for C above it = 3; for E below = -5 etc.
      #
      # @param [Integer] pitch_id the pitch id that we want a frequency for
      # @return [Float] the frequency in hz of the pitch
      #

      def self.equal_frequency( pitch_id )
        compute_octave(440, (pitch_id.to_f/12))
      end

      # Given a fundamental frequency and ratios, this routine will compute a tuning and return the results
      #
      # @param [Float] fundamental the starting frequency of the octave we wish to compute
      # @param [Array] tuning_ratios an array of tuning ratios to apply against the fundamental
      # @return [Array] an array of frequencies, each representing one degree of the spectrum
      # TODO Test
      # TODO Test depends on loading tuning files for the ratios

      def self.compute_tuning( fundamental, tuning_ratios )
        spectrum = [fundamental]
        tuning_ratios.each do |ratio|
          frequency = fundamental * ratio
          break if frequency > MiltonsMachine::Core::Constants::MAX_HUMAN_HEARING
          spectrum << frequency
        end
        spectrum
      end

      # Given a pitch id, return the MIDI representation of the note
      #
      # ex: the pitch id for A at 440 hz = 0; for C above it = 3; for E below = -5 etc.
      #
      # @param [Integer] pitch_id the pitch id that we want translated to MIDI note id
      # @return [Integer] the MIDI note id
      #

      def self.pitch_id_to_midi( pitch_id )
        69 + pitch_id
      end

      # Given a MIDI note id, translate it to pitch id representation
      #
      # @param [Integer] midi_note_id the MIDI note id that we want translated to pitch id
      # @return [Integer] the pitch id
      #

      def self.midi_to_pitch_id( midi_note_id )
       midi_note_id - 69
      end

      # Given a pitch id, return the pitch class representation of the note
      #
      # @param [Integer] pitch_id the id of the note we wish translated
      # @return [Integer] the pitch class representation of the note
      #

      def self.pitch_to_pitch_class( pitch_id )
       (pitch_id + 9) % 12
      end

      # Given a midi id, return the pitch class representation of the note
      #
      # @param [Integer] midi_id the id of the note we wish translated
      # @return [Integer] the pitch class representation of the note
      #

      def self.midi_to_pitch_class( midi_id )
        pitch_to_pitch_class(midi_to_pitch_id(midi_id))
      end
    end
  end
end
