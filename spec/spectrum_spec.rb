require 'miltons_machine'

describe MiltonsMachine::Core::Spectrum do

  context "when performing permutation operations" do

    it "should compute the harmonic series correctly" do
      input_frequency = 440.345
      solution_set = [440.345, 880.69, 1321.035, 1761.38, 2201.725, 2642.07, 3082.415, 3522.76, 3963.105, 4403.45,
                      4843.795, 5284.14, 5724.485, 6164.83, 6605.175, 7045.52, 7485.865, 7926.21, 8366.555,
                      8806.9, 9247.245, 9687.59, 10127.935, 10568.28, 11008.625, 11448.97, 11889.315, 12329.66,
                      12770.005, 13210.35, 13650.695, 14091.04, 14531.385, 14971.73, 15412.075, 15852.42, 16292.765,
                      16733.11, 17173.455, 17613.8, 18054.145, 18494.49, 18934.835, 19375.18, 19815.525, 20255.87,
                      20696.215, 21136.56, 21576.905, 22017.25, 22457.595, 22897.94, 23338.285, 23778.63, 24218.975,
                      24659.32, 25099.665, 25540.01, 25980.355]
      final_results = MiltonsMachine::Core::Spectrum.compute_harmonics( input_frequency )
      final_results.map!{ |frequency| frequency = frequency.round(3) }
      final_results.should eq(solution_set)
    end

    it "should compute the subharmonic series correctly" do
      input_frequency = 440.345
      solution_set = [440.345, 220.173, 146.782, 110.086, 88.069, 73.391, 62.906, 55.043, 48.927, 44.035, 40.031,
                      36.695, 33.873, 31.453, 29.356, 27.522, 25.903, 24.464, 23.176, 22.017, 20.969, 20.016,
                      19.145, 18.348, 17.614, 16.936, 16.309, 15.727, 15.184, 14.678, 14.205, 13.761, 13.344,
                      12.951, 12.581, 12.232, 11.901, 11.588, 11.291, 11.009, 10.74, 10.484, 10.241, 10.008]
      final_results = MiltonsMachine::Core::Spectrum.compute_subharmonics( input_frequency )
      final_results.map!{ |frequency| frequency = frequency.round(3) }
      final_results.should eq(solution_set)
    end

    it "should compute the Tartini sums and differences correctly" do
       input_frequency_1 = 440     # A
       input_frequency_2 = 493.88  # B above it
       solution_hash = { difference: 53.88, sum: 933.88 }
       final_results = MiltonsMachine::Core::Spectrum.compute_tartini( input_frequency_1, input_frequency_2 )
       solution_hash[:difference].should eq(final_results[:difference].round(2))
       solution_hash[:sum].should eq(final_results[:sum].round(2))
     end

  end

  context "when performing translation operations" do

    it "should compute equal temperament frequency correctly" do
      final_result = []
      solution_set = [174.61, 185.0, 196.0, 207.65, 220.0, 233.08, 246.94, 261.63, 277.18, 293.66, 311.13, 329.63,
                      349.23, 369.99, 392.0, 415.3, 440.0, 466.16, 493.88, 523.25, 554.37, 587.33, 622.25, 659.26,
                      698.46, 739.99, 783.99, 830.61, 880.0, 932.33, 987.77, 1046.5, 1108.73]
      -16.upto(16) do |n|
        final_result << MiltonsMachine::Core::Spectrum.equal_frequency(n).round(2)
      end
      final_result.should eq(solution_set)
    end

    it "should translate pitch id to MIDI note id correctly" do
      final_result = []
      solution_set = [49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72,
                      73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89]
      -20.upto(20) do |n|
          final_result << MiltonsMachine::Core::Spectrum.pitch_id_to_midi(n)
      end
      final_result.should eq(solution_set)
    end

    it "should translate MIDI note id to pitch id correctly" do
      final_result = []
      solution_set = [-9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
      60.upto(80) do |n|
          final_result << MiltonsMachine::Core::Spectrum.midi_to_pitch_id(n)
      end
      final_result.should eq(solution_set)
    end

    it "should translate pitch id to pitch class representation" do
      final_result = []
      solution_set = [9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      -12.upto(12) do |n|
          final_result << MiltonsMachine::Core::Spectrum.pitch_to_pitch_class(n)
      end
      final_result.should eq(solution_set)
    end

    it "should translate midi id to pitch class representation" do
      final_result = []
      solution_set = [7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      55.upto(82) do |n|
          final_result << MiltonsMachine::Core::Spectrum.midi_to_pitch_class(n)
      end
      final_result.should eq(solution_set)
    end

  end

end