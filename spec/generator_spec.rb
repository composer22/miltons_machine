require 'miltons_machine'

describe MiltonsMachine::Tools::Generator do

  context "when performing permutation operations" do

    it "should permutate set pairs correctly" do
      input_sets    = [[0, 1, 2], [2, 1, 0],
                       [3, 4, 5], [5, 4, 3]]

      solution_sets = [[[0, 1, 2], [3, 4, 5]],
                       [[0, 1, 2], [5, 4, 3]],
                       [[2, 1, 0], [3, 4, 5]],
                       [[2, 1, 0], [5, 4, 3]],
                       [[3, 4, 5], [0, 1, 2]],
                       [[3, 4, 5], [2, 1, 0]],
                       [[5, 4, 3], [0, 1, 2]],
                       [[5, 4, 3], [2, 1, 0]]]

      final_results = subject.permutate_set_pairs( input_sets )
      final_results.should eq(solution_sets)
    end

    it "should compute the harmonic series correctly" do
      input_frequency = 440
      solution_set = [440, 880, 1320, 1760, 2200, 2640, 3080, 3520, 3960, 4400, 4840, 5280, 5720, 6160, 6600, 7040,
                      7480, 7920, 8360, 8800, 9240, 9680, 10120, 10560, 11000, 11440, 11880, 12320, 12760, 13200,
                      13640, 14080, 14520, 14960, 15400, 15840, 16280, 16720, 17160, 17600, 18040, 18480, 18920,
                      19360, 19800]
      final_results =  subject.compute_harmonics( input_frequency )
      final_results.should eq(solution_set)
    end

    it "should compute the Tartini sums and differences correctly" do
       input_frequency_1 = 440     # A
       input_frequency_2 = 493.88  # B above it
       solution_hash = { difference: 53.88, sum: 933.88 }
       final_results = subject.compute_tartini( input_frequency_1, input_frequency_2 )
       solution_hash[:difference].should eq(final_results[:difference].round(2))
       solution_hash[:sum].should eq(final_results[:sum].round(2))
     end

  end

  context "when performing translation operations" do

    it "should compute equal temperament frequency correctly" do
      final_result = Array.new
      solution_set = [174.61, 185.0, 196.0, 207.65, 220.0, 233.08, 246.94, 261.63, 277.18, 293.66, 311.13, 329.63,
                      349.23, 369.99, 392.0, 415.3, 440.0, 466.16, 493.88, 523.25, 554.37, 587.33, 622.25, 659.26,
                      698.46, 739.99, 783.99, 830.61, 880.0, 932.33, 987.77, 1046.5, 1108.73]
      -16.upto(16) do |n|
        final_result << subject.compute_equal_frequency(n).round(2)
      end
      final_result.should eq(solution_set)
    end

    it "should translate pitch id to MIDI note id correctly" do
      final_result = Array.new
      solution_set = [49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72,
                      73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89]
      -20.upto(20) do |n|
          final_result << subject.convert_to_midi_note(n)
      end
      final_result.should eq(solution_set)
    end

    it "should translate MIDI note id to pitch id correctly" do
      final_result = Array.new
      solution_set = [-9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
      60.upto(80) do |n|
          final_result << subject.convert_to_pitch_id(n)
      end
      final_result.should eq(solution_set)
    end

    it "should translate pitch id to pitch class representation" do
      final_result = Array.new
      solution_set = [9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      -12.upto(12) do |n|
          final_result << subject.convert_pitch_to_pitch_class(n)
      end
      final_result.should eq(solution_set)
    end

    it "should translate midi id to pitch class representation" do
      final_result = Array.new
      solution_set = [7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      55.upto(82) do |n|
          final_result << subject.convert_midi_to_pitch_class(n)
      end
      final_result.should eq(solution_set)
    end

  end

end