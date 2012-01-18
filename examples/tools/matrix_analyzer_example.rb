require "miltons_machine"

# An example on how to use the MatrixAnalyzer to find the most saturated harmonies from a number of permutations.
# Useful for counterpoint construction.
#
# @example "row row row your boat"
#
#    Output sample - one detail analysis of a possible rotation and the run summary:
#
#    [0, 0, 0, 4, 4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0]  Group 1 <== original melody
#    [4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0, 0, 0, 0, 4]  Group 2 <== melody rotated 12x
#    [0, 7, 2, 0, 7, 3, 0, 0, 0, 0, 0, 4, 4, 4, 7, 7]  Group 3 <== melody rotated 8x
#    ----------
#    [0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1]  Score  <== the # maj/min sets (analysis)
#    Total Score: 6
#
#    ...
#    Score : # Instances
#    -------------------
#        0 :    46
#        1 :    18
#        2 :    48
#        3 :    72
#        4 :    24
#        5 :    42
#        6 :     6  <== most saturated found = 6 solutions ex: the detail above
#
# ex:  there are 42 permutation solutions that have 5 columns holding major or minor chords
#

melody = [0, 0, 0, 4, 4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0]     # from the beats of the melody

# Sonorities to search for
major =  [0, 4, 7]                                            # 3-11i
minor =  [0, 3, 7]                                            # 3-11

analysis_engine = MiltonsMachine::Tools:MatrixAnalyzer.new
analysis_engine.report_details=(true)

# First add the rows.  Three voices = triadic; independent in separate groups
analysis_engine.add_row(1, melody)
analysis_engine.add_row(2, melody)
analysis_engine.add_row(3, melody)

# Then, create all transpositions of sets to search for:
0.upto(11) do |i|
  analysis_engine.add_search_set(major, i)                # TnI
  analysis_engine.add_search_set(minor, i)                # Tn
  #  analysis_engine.add_forte_set("3-11", i)             # Tn  <== or optionally use Forte Set names like here
  #  analysis_engine.add_forte_set("3-11i", i)            # TnI
end

analysis_engine.run_rotation_analysis
