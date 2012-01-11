module MiltonsMachine
  module Core

    #
    # == Class: Math
    #
    # This class provides additional additional methods and services not found in the standard library
    #

    class Math   # no monkey patching

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

      #
      # Quantize a given number using the Middle Riser Uniform Quantizer algorithm
      # @see http://en.wikipedia.org/wiki/Quantization_(signal_processing)
      #
      # @param [Numeric] input teh value we wish to quantize
      # @param [Numeric] step the quantization step size
      # @return [Float] the quantized value
      #

      def self.quantize( input, step = 1.00 )
        (step * ( (input / step ) + 0.5 )).floor
      end

    end
  end
end

