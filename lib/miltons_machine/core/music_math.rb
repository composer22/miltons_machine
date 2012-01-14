module MiltonsMachine
  module Core

    #
    # == Class: MusicMath
    #
    # This class provides additional additional methods and services not found in the standard library
    #

    class MusicMath   # no monkey patching

      # Given a set of ordered numbers, compute the differences between each pair
      #
      # @param [Array] input_set the set of numbers we want deltas
      # @return [Array] an array of deltas or differences
      #

      def self.compute_deltas( input_set )
        result = []
        input_set.each_with_index do |input, index|
          next if index == 0
          result << (input_set[index - 1] - input)
        end
        result
      end

      # Quantize a given number using the Middle Riser Uniform Quantizer algorithm
      # @see http://en.wikipedia.org/wiki/Quantization_(signal_processing)
      #
      # @param [Numeric] input the value we wish to quantize
      # @param [Numeric] step the quantization step size
      # @return [Float] the quantized value
      #

      def self.quantize( input, step = 1.00 )
        (step * ( (input / step ) + 0.5 )).floor
      end

      # Converts a rhythm unit to it's equivalent of time unit.
      #
      # @param [Numeric] rhythm a fraction of a whole note
      # @param [Numeric] beat the unit for a given measure - for example 1/4 = beat in 4/4 time
      # @param [Numeric] tempo how many beats per unit of time ex: a 58 Metronome Mark would equal 58
      # @param [Numeric] unit_of_time the time in seconds ex: 58 Metronome Mark would be 60 seconds (e.g 1 minute)
      # @return [Float] the equivalent time value
      #

      def self.convert_rhythm( rhythm, beat, tempo, unit_of_time = 60.00 )
        ( rhythm / beat) * ( unit_of_time / tempo )
      end

      # Converts a scaled values into a new range
      #
      # @param [Numeric] value the value tha we wish to rescale
      # @param [Range] old_scale the scale or range that the value originated in
      # @param [Range] new_scale the new scale that we wish to stretch or shrink the value into
      # @param [Numeric] base the optional exponent of operations
      # @return [Float] the new value as a member of the new scale
      #

      def self.rescale( value, old_scale, new_scale, base = 1.00)
        return new_scale.last if value >= old_scale.last
        return new_scale.first  if value <= old_scale.first
        if base == 1.00
           return ( (( new_scale.last - new_scale.first) / (old_scale.last.to_f - old_scale.first)) *
                    (value - old_scale.first) ) + new_scale.first
        end

        # This looks more complicated than it is super-folded up
        ( ((new_scale.last - new_scale.first) / (base.to_f - 1.00)) *
            ((base.to_f ** ((value - old_scale.first) / (old_scale.last.to_f - old_scale.first)) ) - 1.0) )  +
            new_scale.first
      end

      # Return a random value between a range
      #
      # @param [Range] range the range to find a random number value between
      # @return [Float] a new random value
      #
      def self.random(range)
        return range.first if range.first == range.last
        range.first + (Random.new.rand * (range.last - range.first).abs)
      end

    end
  end
end

