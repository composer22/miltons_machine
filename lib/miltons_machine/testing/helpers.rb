#
# == Module: MiltonsMachine::Testing::Helpers
#
# This module contains routines, classes, etc that can be shared between test scripts
#

module MiltonsMachine
  module Testing
    module Helpers

      # Use this method to capture the streams of stdin, stdout, stderr into a string
      # so that it can be scanned for expected output
      #
      # @example
      #
      #   # stdout only
      #
      #   @output = capture(:stdout) { subject.run_rotation_analysis) }
      #
      #   # stderr only
      #
      #   @output = caputre(:stderr) { subject.run_rotation_analysis }
      #
      #   # stdout + stderr
      #
      #   @output = capture(:stdout, :stderr) { subject.run_rotation_analysis }
      #
      # @param [Array] streams what streams we should capture
      # @return [String] a copy of the stream in a string

      def capture(*streams)
        streams.map! { |stream| stream.to_s }
        result = StringIO.new
        begin
          streams.each { |stream| eval "$#{stream} = result" }
          yield
        ensure
          streams.each { |stream| eval("$#{stream} = #{stream.upcase}") }
        end
        result.string
      end

    end
  end
end