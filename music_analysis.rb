require 'set'
require './forte_sets'                      # temp tag here until we gem it

# ============================================================================
# Class: Musical Matrix Analyzer
#
# Given an array where each element in the array is a group of rows - each row representing ordered musical pitches.
# Permutate each group of rows in parallel using rotation.  After each rotation search each column (intersecting all
# groups) for a pattern of sonorities from a dictionary. If a sonority is found, then tabulate a score for comparison
# reporting.
#
# Useful for counterpoint such as creating a canon, composing 12t, or deriving set related composition designs
#
# To provide some visual explanation - in the following matrix each group is rotated to permutate
# possibilities of columns being aligned to optimal search patterns.  Group 1's rows are not rotated but remains fixed.
# Group 2's rows are rotated once.  Group 3's rows are rotated once for each position of Group 2.  Since there are
# 16 columns, Group 3's rows will be rotated 16 * 16 times = 256.  e.g. there will be 256 permutations for the run.
#
#       [0, 0, 0, 4, 4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0]    Group 1
#
#       [7, 7, 0, 7, 2, 1, 7, 3, 0, 0, 0, 9, 0, 4, 4, 4]    Group 2 each row is rotated in parallel 16x ==>
#       [4, 4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0, 0, 0, 0]
#
#       [4, 7, 7, 0, 7, 2, 1, 7, 3, 0, 0, 0, 9, 0, 4, 4]    Group 3 each row is rotated in parallel 16x16 times ==>
#       [0, 4, 4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0, 0, 0]
#
#       Each permutation will be checked to see if there are sonorities (vertical harmonies) we are searching.
#
# NOTE: Performance is an issue right now with larger number of voices and pitches since performance is measured
#       from: number of permutations =  x^(n-1) where x = number of columns and n is the number of groups.
#
#       For example:  50 columns and 8 groups of one row in each group would generate 50^7 permutations
#                     or 781,250,000,000 possible rotations to search through.
#
# example: "row row row your boat"
#
# From the beats of the melody:
#
#    melody = [0, 0, 0, 4, 4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0]
#
# Sonorities to search for:
#
#    major = [0, 4, 7]    # 3-11i
#    minor = [0, 3, 7]    # 3-11
#
# == Code example:
#
#    melody = [0, 0, 0, 4, 4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0]
#    major =  [0, 4, 7]
#    minor =  [0, 3, 7]
#
#    analysis_engine = MatrixAnalyzer.new()
#    analysis_engine.report_details=(true)
#
#    # First add the rows.  Three voices = triadic; independent in separate groups
#    analysis_engine.add_row(1, melody)
#    analysis_engine.add_row(2, melody)
#    analysis_engine.add_row(3, melody)
#
#    # Then, create all transpositions of sets to search for:
#    0.upto(11) do |i|
#      analysis_engine.add_search_set(major, i)                # TnI
#      analysis_engine.add_search_set(minor, i)                # Tn
#      #  analysis_engine.add_forte_set("3-11", i)             # Tn      <== or optionally use Forte Set names
#      #  analysis_engine.add_forte_set("3-11i", i)            # TnI     <== or optionally use Forte Set names
#    end
#
#    analysis_engine.run_analysis()
#
#    Output sample - one detail analysis of a possible rotation and the run summary:
#
#    [0, 0, 0, 4, 4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0]  Group 1 <== original melody
#    [4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0, 0, 0, 0, 4]  Group 2 <== melody rotated 12x
#    [0, 7, 2, 0, 7, 3, 0, 0, 0, 0, 0, 4, 4, 4, 7, 7]  Group 3 <== melody rotated 8x
#    ---------
#    [0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1]  Score  <== the # maj/min sets (analysis)
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
#   TODO More report filtering options and statistic measurements
#   TODO Allow for horizontal searches
#   TODO Performance improvement - allow for start and stop rotation indexes so work can be broken up
#   TODO Performance improvement - parallel forking/threads, better algorithms etc...
# =============================================================================

class MatrixAnalyzer

  attr_accessor :minimax_score      # Range object - minimum to maximum score that must be met in the results for a
                                    # solution to be counted. default = 0..9999999

  attr_accessor :report_details     # If true, show details of the analysis, else summary only. default = false

  attr_accessor :groups             # A 3d array for holding horizontal ordered sets (rows) - each set:
                                    # 1) representing an ordered voice of pitches in the matrix
                                    # 2) should be rotatable like a cannon
                                    # 3) encoded in mod12 pitch class notation (0 = c up to 11 = b)

  attr_accessor :search_sets        # A 2d array for holding set of pitches to analyze when looking for vertical
                                    # sonorities.  These should already be transformed using Tn or TnI

  attr_accessor :summary_totals     # Used to collect a final tally of subsets found. For example:
                                    # summary_totals[9] = 21 means 21 permutations had 9 subsets found in each

  attr_accessor :rotation_count     # Used to count the total number of permutations (rotations) performed by the run.

  attr_accessor :maximum_rotations  # A calculation of the total number of rotations that this process will produce.

  protected     :groups, :search_sets, :summary_totals, :rotation_count, :maximum_rotations

  public

  # Constructor
  #
  # all parameters are optional
  #
  # * *Parameters*    :
  #   - +minimax_score+ [Range] -> Minimum to maximum score to display
  #   - +max_score+ [Integer] -> Maximum score to display
  #   - +report_details+ [Boolean] -> If true, show details, else summary only  default false
  # * *Returns* :
  #   - [Object] -> a new MatrixAnalyzer Object
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil or wrong type
  #

  def initialize(minimax_score = Range.new(0, 99999999), report_details = false)
    raise ArgumentError, "minimax_score must a Range object" unless(minimax_score.instance_of?(Range))
    raise ArgumentError, "report_details must a boolean value" unless(report_details.instance_of?(TrueClass) ||
                                                                      report_details.instance_of?(FalseClass))
    @minimax_score     = minimax_score
    @report_details    = report_details
    @groups            = Array.new()
    @search_sets       = Array.new()
    @summary_totals    = Array.new()
    @rotation_count    = 0
    @maximum_rotations = 0
  end

  # Insert a row into the matrix of voices to search
  #
  # * *Parameters* :
  #   - +group_id+ [Integer] -> The group id to add it to (1 - n)
  #   - +row+ [Array] -> An array of ordered pitches (voice)
  #   - +transpose+ [Integer] -> transpose this array Tn 0-11 default = 0
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil
  #

  def add_row(group_id, row, transpose = 0)
    raise ArgumentError, "group_id is mandatory" if(group_id.nil?)
    raise ArgumentError, "group_id must an integer" unless(group_id.instance_of?(Fixnum))
    raise ArgumentError, "group id must be > 0" unless(group_id > 0)
    raise ArgumentError, "row is mandatory" if(row.nil?)
    raise ArgumentError, "row must an Array object" unless(row.instance_of?(Array))
    raise ArgumentError, "transpose must an integer" unless(transpose.instance_of?(Fixnum))
    raise ArgumentError, "transpose must be between 0 and 11" unless((0..11).include?(transpose))

    @groups[group_id - 1] ||= Array.new()
    @groups[group_id - 1] << ForteSets.instance.transpose_set(row, transpose)
  end

  # Insert a set into the search dictionary
  #
  # * *Parameters* :
  #   - +search_set+ [Array] -> The target set we are searching
  #   - +transpose+ [Integer] -> Transpose the submitted set + n (optional)
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil or wrong type
  #

  def add_search_set(search_set, transpose = 0)
    raise ArgumentError, "search_set is mandatory" if(search_set.nil?)
    raise ArgumentError, "search_set must an Array object" unless(search_set.instance_of?(Array))
    raise ArgumentError, "transpose must an integer" unless(transpose.instance_of?(Fixnum))
    raise ArgumentError, "transpose must be between 0 and 11" unless((0..11).include?(transpose))

    @search_sets << Set.new(ForteSets.instance.transpose_set(search_set, transpose))
  end

  # Insert a forte set into the search dictionary
  #
  # * *Parameters* :
  #   - +forte_set+ [String] -> The target set name we are searching
  #   - +transpose+ [Integer] -> Transpose the submitted set + n (optional)
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil or wrong type
  #   - +KeyError+ -> could not find forte_set
  #

  def add_forte_set(forte_set, transpose = 0)
    raise ArgumentError, "forte_set is mandatory" if(forte_set.nil?)
    raise ArgumentError, "forte_set must a String object" unless(forte_set.instance_of?(String))
    raise ArgumentError, "transpose must an integer" unless(transpose.instance_of?(Fixnum))
    raise ArgumentError, "transpose must be between 0 and 11" unless((0..11).include?(transpose))

    search_set = ForteSets.instance.get_set(forte_set)
    raise KeyError, "forte_set could not be found" if(search_set.nil?)
    @search_sets << Set.new(ForteSets.instance.transpose_set(search_set, transpose))
  end

  # Run the analysis and print out the results
  #
  # Non recursive option is only there to compare performance of two coding techniques, and they are not all that
  # different in performance, surprisingly. =(
  #
  # * *Parameters* :
  #   - +recursive+ [Boolean] -> true = run recursively (default) false = run experimental brute force
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil or wrong type
  #

  def run_analysis(recursive = true)
    raise ArgumentError, "recursive must a boolean value" unless(recursive.instance_of?(TrueClass) ||
                                                                 recursive.instance_of?(FalseClass))
    self.initialize_run()
    recursive == true ? self.rotate_group() : self.rotate_experiment()
    self.print_summary()
  end

  protected

  # Initialize the environment before the analysis is run
  #
  # * *Parameters* :
  #   - none
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - none
  #
  def initialize_run()
    @summary_totals.clear()
    @rotation_count = 0

    #  Calculate total number of rotation permutations for the run.
    number_of_columns = @groups[0][0].length()
    number_of_groups  = @groups.length() - 1
    @maximum_rotations = number_of_columns ** number_of_groups
  end

  # A recursive routine that rotates a group of voices in the horizontal matrix.  If it is at depth, performs the
  # final vertical analysis for the current rotations; otherwise, just calls itself to process the next group in the
  # hierarchy.
  #
  # * *Parameters* :
  #   - +level+ [integer] -> Depth/group indicator in recursion (optional)
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - none
  #

  def rotate_group(level = -1)
    level += 1

    unless(level > 0)                                          # First group always remains static
      self.rotate_group(level)                                 # Recursive call to process next group of rows
    else
      # Rotate each pitch to the right for each row in this group.  If its the last group then analyze the verticals
      # in each column across all groups; otherwise recursively call to process next group of rows.

      max_group_index   = @groups.length() - 1
      max_column_index  = @groups[0][0].length() - 1
      0.upto(max_column_index) do
        @groups[level].each{ |row| row.rotate!(-1) }
        level == max_group_index ? self.analyze_sonorities() : self.rotate_group(level)
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

    @groups[0][0].each_index() do |column_id|        # Loop on number of number of columns
      result_counts[column_id] = 0                   # Initialize counter for column
      sonority_to_test.clear()

      # Slice through the voices of all groups and their rows to create a sonority to test.
      @groups.each_index() do |group_id|
        @groups[group_id].each_index(){ |row_id| sonority_to_test.add(@groups[group_id][row_id][column_id]) }
      end

      # Search the dictionary of vertical sets we are looking for and increment column counter if found.
      @search_sets.each{ |set_to_search| result_counts[column_id] += 1 if(set_to_search.subset?(sonority_to_test)) }
    end

    # Accumulate a cross total of column result to create a final score for the current rotation snapshot.
    score = result_counts.inject(0){ |sum, col_result| sum += col_result }

    # If we meet the search criteria then add results to report totals and optionally print details.
    if(@minimax_score.include?(score))
      self.accumulate_summary_totals(score)

      # Optionally print details of this rotation snapshot.
      self.print_details(result_counts, score) if(@report_details)
    end

    self.print_rotation_count() unless(@report_details)

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
  #   - none
  #

  def accumulate_summary_totals(score)
    @summary_totals[score] ||= 0
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
  #   - none
  #

  def print_details(result_counts, score)
    puts ('=' * 10) << "\n"
    @groups.each_with_index(){ |group, n | group.each(){ |row| puts row.to_s << " Group " << (n + 1).to_s }}
    puts  '-' *  (@groups[0][0].length() * 3)
    puts result_counts.to_s << " Score"
    puts "\nTotal Score: " << score.to_s << "\n"
  end

  # Print out a progress indicator of how many rotations / permutations have been processed and how many are remaining.
  #
  # * *Parameters* :
  #   - none
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - none
  #

  def print_rotation_count()
    @rotation_count += 1
    print "\r\e#{@rotation_count} of #{@maximum_rotations} processed..."
    $stdout.flush
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
    puts "\n\nScore : # Instances\n" << ("=" * 19)
    @summary_totals.each_with_index { |value, index| puts " %5d:%8d\n" % [index, value] unless(value.nil?) }
    puts "\n** End of Report"
  end

  # EXPERIMENTAL ONLY
  #
  # A NON-recursive SINGLE inline routine that emulates the same functionality of rotate_group() including all
  # sub-calls. This is only here for experimenting with maximizing performance over recursive descent methods.
  # Honestly, I haven't found any difference on larger matrix's yet.
  #
  # * *Parameters* :
  #   - none
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - none
  #

  def rotate_experiment()
    max_group_index       = @groups.length() - 1
    max_column_index      = @groups[0][0].length() - 1
    last_rotation_counter = Array.new(max_group_index + 1)
    last_level_processed  = 0
    current_level         = 1
    rotation_counter      = 0
    group                 = nil

    sonority_to_test      = Set.new()            # A work space for a vertical slice
    result_counts         = Array.new()          # Success counters for each column

    while current_level > 0 do
      # Fill work variables when first entering or returning to this level
      if(current_level != last_level_processed)
        rotation_counter = last_rotation_counter.at(current_level)
        rotation_counter ||= -1
        group = @groups[current_level]
      end

      last_level_processed = current_level

      # If no more columns to rotate then stop processing row...
      if(rotation_counter == max_column_index)
        last_rotation_counter[current_level] = -1                # Rewind
        current_level -= 1                                       # Go up a level
        next
      end

      @groups[current_level].each{ |row| row.rotate!(-1) }
      rotation_counter += 1

      # Leaf row gets to analyze columns, otherwise go deeper.
      if(current_level != max_group_index)
        last_rotation_counter[current_level] = rotation_counter  # Save index
        current_level += 1                                       # Call
        next
      end

      # BEGIN  merge analyze_sonorities() code run

      # Loop on columns in the matrix and extract out the sonority. Compare that to the dictionary of vertical sets to
      # calculate a score for each column.

      @groups[0][0].each_index() do |column_id|        # Loop on number of number of columns
        result_counts[column_id] = 0                   # Initialize counter for column
        sonority_to_test.clear()

        # Slice through the voices of all groups and their rows to create a sonority to test.
        @groups.each_index() do |group_id|
          @groups[group_id].each_index(){ |row_id| sonority_to_test.add(@groups[group_id][row_id][column_id]) }
        end

        # Search the dictionary of vertical sets we are looking for and increment column counter if found.
        @search_sets.each{ |set_to_search| result_counts[column_id] += 1 if(set_to_search.subset?(sonority_to_test)) }
      end

      # Accumulate a cross total of column result to create a final score for the current rotation snapshot.
      score = result_counts.inject(0){ |sum, col_result| sum += col_result }

      # If we meet the search criteria then add results to report totals and optionally print details.
      if(@minimax_score.include?(score))
        @summary_totals[score] ||= 0
        @summary_totals[score] += 1

        # Optionally print details of this rotation snapshot.
        if(@report_details)
          puts ('=' * 10) << "\n"
          @groups.each_with_index(){ |g, n | g.each(){ |row| puts row.to_s << " Group " << (n + 1).to_s }}
          puts  '-' *  (@groups[0][0].length() * 3)
          puts result_counts.to_s << " Score"
          puts "\nTotal Score: " << score.to_s << "\n"
        end
      end

      unless(@report_details)
        @rotation_count += 1
        print "\r\e#{@rotation_count} of #{@maximum_rotations} processed in experimental mode..."
        $stdout.flush
      end

      # END merge of analyze_sonorities() code run

    end
  end

end

#melody = [0, 0, 0, 4, 4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0]
#major =  [0, 4, 7]
#minor =  [0, 3, 7]
#
#analysis_engine = MatrixAnalyzer.new()
#analysis_engine.report_details=(true)
#
## First add the rows.  Three voices = triadic
#analysis_engine.add_row(1, melody)
#analysis_engine.add_row(2, melody)
#analysis_engine.add_row(3, melody)
#
## Then, create all transpositions of sets to search for:
#0.upto(11) do |i|
#  #analysis_engine.add_forte_set("3-11", i)     # Tn
#  #analysis_engine.add_forte_set("3-11i", i)     # TnI
#  analysis_engine.add_search_set(major, i)     # Tn
#  analysis_engine.add_search_set(minor, i)     # TnI
#end
#
#analysis_engine.run_analysis()
