require 'set'

module MiltonsMachine
  module Tools
    #
    # == Class: Matrix Analyzer
    #
    # Given an array where each element in the array is a group of rows - each row representing ordered musical pitches:
    # permutate each group of rows in parallel using rotation.  After each rotation search each column (intersecting all
    # groups) for a pattern of sonorities from a dictionary. If a sonority is found, then tabulate a score for
    # comparison reporting.
    #
    # Useful for counterpoint such as creating a canon, composing 12t, or deriving set related composition designs
    #
    # @note Performance is an issue right now with larger number of voices and pitches since performance is measured
    # from: number of permutations =  x^(n-1) where x = number of columns and n is the number of groups.50 columns and
    # 8 groups of one row in each group would generate 50^7 permutations or 781,250,000,000 possible rotations to
    # search through.
    #
    # @see miltons_machine/examples/tools/matrix_analyzer_example.rb for an example.
    #
    # TODO More report filtering options and statistic measurements
    # TODO Performance improvement - allow for start and stop rotation indexes so work can be broken up
    # TODO Performance improvement - parallel forking/threads, better algorithms etc...
    #

    class MatrixAnalyzer

      # Range object - minimum to maximum score that must be met in the results for a solution to be counted.

      attr_accessor :minimax_score

      # Show details of the analysis, else summary only.

      attr_accessor :report_details

      # A 3d array for holding horizontal ordered sets (rows) - each set:
      # 1) representing an ordered voice of pitches in the matrix
      # 2) should be rotatable like a canon
      # 3) encoded in mod12 pitch class notation (0 = c up to 11 = b)

      attr_accessor :groups

      # A 2d array for holding set of pitches to analyze when looking for vertical sonorities.  These should already be
      # transformed using Tn or TnI

      attr_accessor :search_sets

      # Used to collect a final tally of subsets found. For example: summary_totals[9] = 21 means 21 permutations had 9
      # subsets found in each

      attr_accessor :summary_totals

      # The last index of the groups array e.g. length - 1

      attr_accessor :max_group_index

      # The last index of the columns of the rows  e.g. length - 1

      attr_accessor :max_column_index

      # Used to count the total number of permutations (rotations) performed by the run.

      attr_accessor :rotation_count

      # A calculation of the total number of rotations that this process will produce.

      attr_accessor :maximum_rotations

      protected     :groups, :search_sets, :summary_totals, :max_group_index, :max_column_index, :rotation_count,
                    :maximum_rotations

      public

      # Constructor
      #
      # @param [Range] minimax_score Minimum to maximum score to display
      # @param [Boolean] report_details if true, show details, else summary only
      # @return [Object] a new MatrixAnalyzer Object

      def initialize( minimax_score = Range.new(0, 99999999), report_details = false )
        @minimax_score     = minimax_score
        @report_details    = report_details
        @groups            = []
        @search_sets       = []
        @summary_totals    = []
        @max_group_index   = 0
        @max_column_index  = 0
        @rotation_count    = 0
        @maximum_rotations = 0
      end

      # Insert a row into the matrix of voices to search
      #
      # @param [Integer] group_id The group id to add it to (1 - n)
      # @param [Array] row an array of ordered pitches (voice)
      # @param [Integer] number_to_transpose transpose this array Tn 0-11
      #

      def add_row( group_id, row, number_to_transpose = 0 )
        @groups[group_id - 1] ||= []
        @groups[group_id - 1] << MiltonsMachine::Core::ForteSet.new(row).transpose_mod12(number_to_transpose)
        @max_group_index  = @groups.length - 1
        @max_column_index = @groups[0][0].length - 1
      end

      # Insert a set into the search dictionary
      #
      # @param [Array] search_set the target set we are searching
      # @param [Integer] number_to_transpose transpose the submitted set + n
      #

      def add_search_set( search_set, number_to_transpose = 0 )
        @search_sets << Set.new( MiltonsMachine::Core::ForteSet.new(search_set).transpose_mod12(number_to_transpose) )
      end

      # Insert a forte set into the search dictionary
      #
      # @param [String] forte_set_name the target set name we are searching
      # @param [Integer] number_to_transpose transpose the submitted set + n
      # @raise [KeyError] forte_set could not be found

      def add_forte_set( forte_set_name, number_to_transpose = 0 )
        search_set = MiltonsMachine::Core::ForteDictionary.instance.get_set(forte_set_name)
        raise KeyError, "forte_set could not be found" if search_set.nil?

        @search_sets << Set.new( search_set.transpose_mod12(number_to_transpose) )
      end

      # Run the rotation_analysis and print out the results
      #

      def run_rotation_analysis
        initialize_run
        rotate_group
        print_summary
      end

      protected

      # Initialize the environment before the analysis is run
      #

      def initialize_run
        @summary_totals.clear
        @rotation_count = 0

        # Compute total number of rotation permutations for the run.
        # number_of_columns^(number_of_groups - 1)
        @maximum_rotations = @groups[0][0].length ** @max_group_index
      end

      # A recursive routine that rotates a group of voices in the horizontal matrix.  If it is at depth, performs the
      # final vertical analysis for the current rotations; otherwise, just calls itself to process the next group in the
      # hierarchy.
      #
      # @param [integer] level depth/group indicator in recursion
      #

      def rotate_group( level = -1 )
        level += 1

        if level == 0                                       # First group always remains static
          rotate_group(level)                               # Recursive call to process next group of rows
        else
          # Rotate each pitch to the right for each row in this group.  If its the last group then analyze the verticals
          # in each column across all groups; otherwise recursively call to process next group of rows.
          0.upto(@max_column_index) do
            @groups[level].each { |row| row.rotate!(-1) }
            level == @max_group_index ? analyze_sonorities : rotate_group(level)
          end
        end
      end

      # Step through each column in the matrix of rotated rows (voices) and look for patterns of sets from a dictionary
      # to create a score for each column (found) and for the entire matrix of rows (total found).
      #

      def analyze_sonorities
        sonority_to_test = Set.new             # A work space for slicing
        result_counts    = []                  # Success counters of columns

        # Loop on columns in the matrix and extract out the sonority. Compare that to the dictionary of vertical sets to
        # compute a score for each column.

        @groups[0][0].each_index do |column_id|        # Loop on number of number of columns
          result_counts[column_id] = 0                 # Initialize counter for column
          sonority_to_test.clear

          # Slice through the voices of all groups and their rows to create a sonority to test.
          @groups.each_index do |group_id|
            @groups[group_id].each_index { |row_id| sonority_to_test.add( @groups[group_id][row_id][column_id] ) }
          end

          # Search the dictionary of vertical sets we are looking for and increment column counter if found.
          @search_sets.each { |set_to_search| result_counts[column_id] += 1 if set_to_search.subset?(sonority_to_test) }
        end

        # Accumulate a cross total of column result to create a final score for the current rotation snapshot.
        score = result_counts.inject(0) { |sum, col_result| sum += col_result }

        # If we meet the search criteria then add results to report totals and optionally print details.
        if @minimax_score.include?(score)
          accumulate_summary_totals(score)

          # Optionally print details of this rotation snapshot.
          print_details(result_counts, score) if @report_details
        end

        print_rotation_count unless @report_details                # run progress meter if in summary mode

      end

      # Accumulate current permutation search result counts into the reports summary totals.  For example: if the total
      # column score was 9 for the current rotation of the rows, summary_totals[9] would be incremented to reflect that
      # a matrix solution was found with score = 9
      #
      # @param [Integer] score total number of sets found in the current snapshot
      #

      def accumulate_summary_totals( score )
        @summary_totals[score] ||= 0
        @summary_totals[score] += 1
      end

      # Print out the details of each analysis we are looking for
      #
      # @param [Array] result_counts An array of totals for each matrix column
      # @param [Integer] score a cross total of this array for a final score
      #

      def print_details( result_counts, score )
        puts ('=' * 10) << "\n"
        @groups.each_with_index { |group, index| group.each { |row| puts "#{row} Group " << (index + 1).to_s } }
        puts  '-' *  (@groups[0][0].length * 3)
        puts "#{result_counts} Score"
        puts "\nTotal Score: #{score}\n"
      end

      # Print out a progress indicator of how many rotations / permutations have been processed and how many are
      # remaining.
      #

      def print_rotation_count
        @rotation_count += 1
        print "\r\e#{@rotation_count} of #{@maximum_rotations} processed..."
        $stdout.flush
      end

      # Prints a summary section for the entire report
      #

      def print_summary
        puts "\n\nScore : # Instances\n" << ("=" * 19)
        @summary_totals.each_with_index { |value, index| puts " %5d:%8d\n" % [index, value] unless value.nil? }
        puts "\n** End of Report"
      end

    end

  end
end
