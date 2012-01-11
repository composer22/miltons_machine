require 'miltons_machine'

describe MiltonsMachine::Core::Math do

  context "when performing extended general services" do

    it "should calculate deltas correctly" do
      test_set = [1, 5, 4, 23, 8, 6]
      solution_set = [-4, 1, -19, 15, 2]
      result_set = MiltonsMachine::Core::Math.compute_deltas(test_set)
      result_set.should eq solution_set
    end

    it "should normalize information correctly" do
      test_set = [32.4546, 66.9248, 85.18239, 16.238, 23.4122, 4.32]
      solution_set = [44, 79, 97, 28, 35, 16]
      result_set = []
      test_set.each { |item| result_set << MiltonsMachine::Core::Math.quantize(item, 25) }
      result_set.should eq solution_set
    end
  end

end