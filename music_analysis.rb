#!/usr/bin/env ruby

require 'set'

# ============================================================================
# =Class: Musical Matrix Analyzer
#
# Given an array where each element in the array is an ordered voice of pitches (another array), permutate each row
# using rotation and search each column for a pattern of sonorities from a dictionary. If a sonority is found, then
# tabulate a score for reporting.
#
# Useful for counterpoint such as creating a canon, composing 12t, or set related composition designs
#
# NOTE: Performance is an issue with larger number of voices and pitches: x^(n-1) where x = number of pitches in a
#       row/voice and n is the number of rows/voices.
#
#      For example:  50 pitches in 8 voices would generate 50^7 permutations or 781,250,000,000 possible rotations
#                    to search through.
#
# example: "row row row your boat"
#
# Strong beats of melody:
#
#    melody = [0, 0, 0, 4, 4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0]
#
# Sonorities to search for:
#
#    major = [0, 4, 7]
#    minor = [0, 3, 7]
#
# == Code example:
#
#    melody = [0, 0, 0, 4, 4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0]
#    major =  [0, 4, 7]
#    minor =  [0, 3, 7]
#
#    analysis_engine = MatrixAnalyzer.new()
#    analysis_engine.minimum_score=(0)
#    analysis_engine.report_details=(true)
#
#    # First add the rows.  Three voices = triadic
#    analysis_engine.add_horizontal_set(melody)
#    analysis_engine.add_horizontal_set(Array.new(melody))
#    analysis_engine.add_horizontal_set(Array.new(melody))
#
#    # Then, create all transpositions of sets to search for:
#    0.upto(11) do |i|
#      analysis_engine.add_vertical_set(Array.new(major), i)     # Tn
#      analysis_engine.add_vertical_set(Array.new(minor), i)     # TnI
#    end
#
#    analysis_engine.run_set_analysis()
#
#    Output sample - one detail analysis of a possible rotation and the run summary:
#
#    [0, 0, 0, 4, 4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0]  <== original melody
#    [4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0, 0, 0, 0, 4]  <== melody rotated 12x
#    [0, 7, 2, 0, 7, 3, 0, 0, 0, 0, 0, 4, 4, 4, 7, 7]  <== melody rotated 8x
#    ---------
#    [0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1]  <== the maj/min sets
#    Total Score: 6
#
#    ...
#    Score : # Instances
#    ===================
#        0 :    46
#        1 :    18
#        2 :    48
#        3 :    72
#        4 :    24
#        5 :    42
#        6 :     6  <== most saturated found = 6 solutions
#                       ex: the detail above
#
#    ex:  there are 42 permutation solutions that have 5 columns holding major or minor chords
#
#   TODO More report filtering and statistics
#   TODO Allow groups of arrays as a single row for rotation
#   TODO Allow for smaller subset comparison in the search dictionary
#   TODO Allow for horizontal searches
#   TODO Allow for Forte prime search sets ex: 3-11 = [0, 3, 7] = minor/major
#   TODO Performance improvements e.g. parallel forking/threads, algorithms
#   TODO Allow for start/stop indexes on each row - easier to parallelize
# =============================================================================

class MatrixAnalyzer

  attr_accessor :minimum_score   # Minimum score that must be met in the results for a solution to be displayed.
                                 # default = 0

  attr_accessor :maximum_score   # Maximum score that the result must be under for a solution to be displayed.
                                 # default = 99999999

  attr_accessor :report_details  # If true, show details of the analysis, else summary only. default = false

  # @horizontal_sets             - A 2d array for holding horizontal ordered sets (rows) - each set:
  #                                1) representing an ordered voice of pitches in the matrix
  #                                2) should be rotatable like a cannon
  #                                3) encoded in mod12 pitch class notation (0 = c up to 11 = b)
  #
  # @vertical_sets               - A 2d array for holding set of pitches to analyze when looking for vertical
  #                                sonorities.  These should be transformed using Tn or TnI
  #
  # @summary_totals              - Used to collect a final tally of subsets found. For example:
  #                                summary_totals[9] = 21 means 21 permutations had 9 subsets found in each
  #

  public

  # Constructor
  #
  # all parameters are optional
  #
  # * *Parameters*    :
  #   - +min_score+ [Integer] -> Minimum score to display
  #   - +max_score+ [Integer] -> Maximum score to display
  #   - +report_details+ [Boolean] -> If true, show details, else summary only
  # * *Returns* :
  #   - [Object] -> a new MatrixAnalyzer Object
  # * *Raises* :
  #   - none
  #

  def initialize(min_score = 0,
                 max_score = 99999999,
                 report_details = false)
    @horizontal_sets = Array.new()
    @vertical_sets = Array.new()
    self.minimum_score=(min_score)
    self.maximum_score=(max_score)
    self.report_details=(report_details)
    @summary_totals = Array.new()
  end

  # Insert a row into the matrix of voices to search
  #
  # * *Parameters* :
  #   - +horizontal_set+ [Array] -> An array of voices
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil
  #

  def add_horizontal_set(horizontal_set)
    raise ArgumentError, "horizontal_set is mandatory" if(horizontal_set.nil?)
    @horizontal_sets << horizontal_set
  end

  # Insert a set into the search dictionary
  # * *Parameters* :
  #   - +vertical_set+ [Array] -> The target set we are searching
  #   - +transpose+ [Integer] -> Transpose the submitted set + n (optional)
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil
  #

  def add_vertical_set(vertical_set, transpose = 0)
    raise ArgumentError, "vertical_set is mandatory" if(vertical_set.nil?)
    vertical_set.collect!{ |pc| pc = transpose_mod12(pc, transpose) }
    @vertical_sets << Set.new(vertical_set)
  end

  # Run the analysis and print out the results
  #
  # Non recursive option is only there to compare performance of two coding techniques, and they are not all that
  # different in performance, surprisingly. =(
  #
  # * *Parameters* :
  #   - +run_recursively+ [Boolean] -> true = run recursively (default)
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - none
  #

  def run_set_analysis(run_recursively = true)
    @summary_totals.clear()
    run_recursively == true ? rotate_via_recursion() : rotate_inline_experiment()
    print_summary()
  end

  protected

  # A recursive routine that rotates a voice in the horizontal matrix of voices.  If it is at depth, performs the
  # final vertical analysis for the current rotations; otherwise, just calls itself to process the next row in the
  # hierarchy of voices.
  #
  # * *Parameters* :
  #   - +level+ [integer] -> Depth/row indicator in recursion (optional)
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - none
  #

  def rotate_via_recursion(level = -1)
    level += 1                                        # Increment depth/row indicator

    unless(level > 0)                                 # First voice remains static
      rotate_via_recursion(level)                     # Recursive call to process next row
    else
      max_row_index = @horizontal_sets.length() - 1
      row           = @horizontal_sets[level]         # Get row for this depth

      # Rotate each pitch to the right for this row.  If its the last row then analyze the verticals in each column
      # across all rows, otherwise recursively call to process next row.
      row.each_index() do
        row.rotate!(-1)
        level == max_row_index ? analyze_sonorities() : rotate_via_recursion(level)
      end
    end
  end

  # Step through each column in the matrix of rotated rows (voices) and look for patterns of sets from a dictionary
  # to create a score for each column (found) and for the entire matrix of rows (total found).
  #
  # * *Parameters* :
  #   - none
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - none
  #

  def analyze_sonorities()
    sonority_to_test = Set.new()             # A work space for slicing
    result_counts    = Array.new()           # Success counters of columns

    # Loop on columns in the matrix and extract out the sonority. Compare that to the dictionary of vertical sets to
    # calculate a score for each column.
    @horizontal_sets[0].each_index() do |i|
      result_counts[i] = 0                   # Initialize counter for column
      sonority_to_test.clear()

      # Slice through the voices to create a sonority to test.
      @horizontal_sets.each_index(){ |j| sonority_to_test.add(@horizontal_sets[j][i]) }

      # Search the dictionary of vertical sets we are looking for and increment column counter if found.
      @vertical_sets.each{ |set_to_search| result_counts[i] += 1 if(sonority_to_test == set_to_search) }
    end

    # Accumulate a cross total of column result to create a final score for the current rotation snapshot.
    total_common_sonorities = result_counts.inject(0){ |sum, col_result| sum += col_result }

    # If we meet the search criteria then add results to report totals and optionally print details.
    if(total_common_sonorities >= self.minimum_score() && total_common_sonorities <= self.maximum_score())
      accumulate_summary_totals(total_common_sonorities)

      # Optionally print details of this rotation snapshot.
      print_details(result_counts, total_common_sonorities) if(self.report_details())
    end
  end

  # Accumulate current snapshot search result counts into the reports summary totals.  For example: if the total column
  # score was 9 for the current rotation of the rows, summary_totals[9] would be incremented to reflect that a matrix
  # solution was found with score = 9
  #
  # * *Parameters* :
  #   - +score+ [Integer] -> Total number of sets found in the current snapshot
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil
  #

  def accumulate_summary_totals(score)
    raise ArgumentError, "score is mandatory" if(score.nil?)
    @summary_totals[score] = 0 if(@summary_totals[score].nil?)  # Initialize first use (this should have been done in
                                                                # initialize())
    @summary_totals[score] += 1
  end

  # Print out the details of each analysis we are looking for
  #
  # * *Parameters* :
  #   - +result_counts+ [Array] -> An array of totals for each matrix column
  #   - +score+ [Integer] -> A cross total of this array for a final score
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil
  #

  def print_details(result_counts, score)
    raise ArgumentError, "result_counts are mandatory" if(result_counts.nil?)
    raise ArgumentError, "score is mandatory" if(score.nil?)
    puts ('=' * 10) << "\n"
    @horizontal_sets.each(){ |line| p line }
    puts  '-' *  (@horizontal_sets[0].length() * 3)
    p result_counts
    puts "\nTotal Score: " << score.to_s << "\n"
  end

  # EXPERIMENTAL ONLY
  #
  # A NON-recursive SINGLE routine that rotates a voice in the horizontal matrix of voices. Exactly the same as
  # rotate_via_recursion(), analyze_sonorities(), accumulate_summary_totals() and print_details() all in one package.
  # This is only for experimenting with maximum optimization by eliminating invocations()
  #
  # * *Parameters* :
  #   - none
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - none
  #

  def rotate_inline_experiment()
    max_row_index         = @horizontal_sets.length() - 1
    max_column_index      = @horizontal_sets[0].length() - 1
    last_rotation_counter = Array.new(max_row_index + 1)
    last_level_processed  = 0
    current_level         = 1
    rotation_counter      = 0
    row                   = nil

    sonority_to_test      = Set.new()            # A work space for a vertical slice
    result_counts         = Array.new()          # Success counters for each column

    while current_level > 0 do
      # Fill work variables when first entering or returning to this level
      if(current_level != last_level_processed)
        rotation_counter = last_rotation_counter.at(current_level)
        rotation_counter = -1 if(rotation_counter.nil?)
        row = @horizontal_sets[current_level]
      end

      last_level_processed = current_level

      # If no more columns to rotate then stop processing row...
      if(rotation_counter == max_column_index)
        last_rotation_counter[current_level] = -1                # Rewind
        current_level -= 1                                       # Go up a level
        next
      end

      row.rotate!(-1)
      rotation_counter += 1

      # Leaf row gets to analyze columns, otherwise go deeper.
      if(current_level != max_row_index)
        last_rotation_counter[current_level] = rotation_counter  # Save index
        current_level += 1                                       # Call
        next
      end

      # Loop on columns in the matrix and extract out the sonority Compare that to the dictionary of vertical sets to
      # calculate a score for each column.
      @horizontal_sets[0].each_index() do |i|
        result_counts[i] = 0                                     # Initialize counter for column
        sonority_to_test.clear()

        # Slice through the voices to create a sonority to test.
        @horizontal_sets.each_index(){ |j| sonority_to_test.add(@horizontal_sets[j][i]) }

        # Search the dictionary of vertical sets we are looking for and increment column counter if found.
        @vertical_sets.each{ |set_to_search| result_counts[i] += 1 if(sonority_to_test == set_to_search) }
      end

      # Accumulate a cross total of column result to create a final score for the current rotation snapshot.
      total_common_sonorities = result_counts.inject(0){ |sum, col_result| sum += col_result }

      # If we meet the search criteria then add results to report totals and optionally print details.
      if(total_common_sonorities >= self.minimum_score() && total_common_sonorities <= self.maximum_score())

        # Accumulate running totals for the report
        @summary_totals[total_common_sonorities] = 0 if(@summary_totals[total_common_sonorities] .nil?)
        @summary_totals[total_common_sonorities] += 1

        # Optionally print details of this rotation snapshot...
        if(self.report_details())
          puts ('=' * 10) << "\n"
          @horizontal_sets.each(){ |line| p line }
          puts  '-' *  (@horizontal_sets[0].length() * 3)
          p result_counts
          puts "\nTotal Score: " << total_common_sonorities.to_s << "\n"
        end
      end
      # END merge of analyze_sonorities() code run

    end
  end

  # Prints a summary section for the entire report
  #
  # * *Parameters* :
  #   - none
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - none
  #

  def print_summary()
    puts "\nScore : # Instances\n" << ("=" * 19)
    @summary_totals.each_with_index { |value, index| puts " %5d:%8d\n" % [index, value] unless(value.nil?) }
    puts "\n** End of Report"
  end

  # Given a musical pitch, and how many 1/2 steps you want to transpose it, returns a new pitch at the new
  # transposition
  #
  # * *Parameters* :
  #   - +pc+ [Integer] -> A pitch to increment 0 = c; 1 = c#...11 = b
  #   - +n+ [Integer] -> Tn or how many steps to increment (optional)
  # * *Returns* :
  #   - [Integer] -> The new transposed pitch
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil
  #

  def transpose_mod12(pc, n = 0)
    raise ArgumentError, "pc is mandatory" if (pc.nil?)
    pc_result = pc + n
    pc_result > 11 ?  pc_result - 12 : pc_result
  end

end

    #melody = [0, 0, 0, 4, 4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0]
    #major =  [0, 4, 7]
    #minor =  [0, 3, 7]
    #
    #analysis_engine = MatrixAnalyzer.new()
    #analysis_engine.minimum_score=(0)
    #analysis_engine.report_details=(true)
    #
    ## First add the rows.  Three voices = triadic
    #analysis_engine.add_horizontal_set(melody)
    #analysis_engine.add_horizontal_set(Array.new(melody))
    #analysis_engine.add_horizontal_set(Array.new(melody))
    #
    ## Then, create all transpositions of sets to search for:
    #0.upto(11) do |i|
    #  analysis_engine.add_vertical_set(Array.new(major), i)     # Tn
    #  analysis_engine.add_vertical_set(Array.new(minor), i)     # TnI
    #end
    #
    #analysis_engine.run_set_analysis()
