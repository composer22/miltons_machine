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

      generator = MiltonsMachine::Tools::Generator.new
			final_results =  generator.permutate_set_pairs( input_sets )
      final_results.should eq(solution_sets)
    end

  end

end