require 'set'

module MiltonsMachine
  module Tools

    #
    # == Class: Generator
    #
    # This tool includes various methods to facilitate the permutation and supply of materials
    # for composition during the course of either composing manually or in real time.
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
      # @example Permutate the following:
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
      # would print out:
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
      # @param [Array] working_sets an array of sets to permutate
      # @return [Array] an array of pairings, less duplicates.
      #

      def permutate_set_pairs( working_sets )
        compare_set1 	= Set.new
        compare_set2 	= Set.new
        final_results = Array.new

        working_sets.repeated_permutation(2) do |resulting_pair|
          # filter out duplicate prime and retrogrades
          unless compare_set1.replace(resulting_pair[0]) == compare_set2.replace(resulting_pair[1])
              final_results << resulting_pair
          end
        end

        final_results
      end
    end

  end
end
