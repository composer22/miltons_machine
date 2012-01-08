require 'set'

require 'miltons_machine'

describe MiltonsMachine::Tools::MatrixAnalyzer do

  include MiltonsMachine::Testing::Helpers

  context "when performing basic operations" do

    it "should add a row" do
      result_set_1 = [0, 1, 2, 3]
      result_set_2 = [4, 5, 6, 7]
      result_set_3 = [8, 9, 10, 11]
      subject.add_row(1, result_set_1)
      subject.add_row(2, result_set_2)
      subject.add_row(3, result_set_3)
      groups = subject.send(:groups)
      groups[0][0].should eq result_set_1
      groups[1][0].should eq result_set_2
      groups[2][0].should eq result_set_3
    end

    it "should add a search set as an array" do
      result_set_1 = [0, 1, 2, 3]
      result_set_2 = [4, 5, 6, 7]
      result_set_3 = [8, 9, 10, 11]
      subject.add_search_set(result_set_1)
      subject.add_search_set(result_set_2)
      subject.add_search_set(result_set_3)
      compare_set = Set.new(result_set_1)
      search_sets = subject.send(:search_sets)
      search_sets[0].should eq compare_set
      search_sets[1].should eq compare_set.replace(result_set_2)
      search_sets[2].should eq compare_set.replace(result_set_3)
    end

    it "should add a search set by Forte set name" do
      subject.add_forte_set('5-3i')
      subject.add_forte_set('7-10')
      subject.add_forte_set('8-18')
      compare_set = Set.new([0, 1, 3, 4, 5])
      search_sets = subject.send(:search_sets)
      search_sets[0].should eq compare_set
      search_sets[1].should eq compare_set.replace([0, 1, 2, 3, 4, 6, 9])
      search_sets[2].should eq compare_set.replace([0, 1, 2, 3, 5, 6, 8, 9])
    end

    it "should run the analysis correctly" do
      melody = [0, 0, 0, 4, 4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0]
      subject.report_details=(true)
      subject.add_row(1, melody)
      subject.add_row(2, melody)
      subject.add_row(3, melody)

      0.upto(11) do |i|
          subject.add_forte_set("3-11", i)
          subject.add_forte_set("3-11i", i)
      end

      compare_string = "1:182:483:724:245:426:6**EndofReport"
      @output = capture(:stdout) { subject.run_rotation_analysis }
      @output = @output[-125..-1]
      @output.delete!("\n ")
      @output.should include(compare_string)
    end

  end

end