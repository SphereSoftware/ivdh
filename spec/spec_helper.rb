$:.unshift File.join(File.dirname(__FILE__), "../lib")
require 'ivdh'
require 'set'

module SpecHelper
  FIXTURES_DIR = File.expand_path(File.dirname(__FILE__) + '/fixtures')
  META_DIR     = File.expand_path(File.dirname(__FILE__) + '/meta_data_dir')

  def find_templates(dir)
    extensions = ["html.erb", "rhtml", "rjs"]
    extensions.map do |ext|
      Dir["**/*#{ext}"].map{|f| File.expand_path(f) }
    end.flatten
  end

  module Expectations
    class BeSameSetAs

      def initialize(expected)
        @expected = expected
      end

      def matches?(target)
        @target = target
        Set.new(@target) == Set.new(@expected)
      end

      def failure_message
        "Expected #{@target.inspect} to be the same set as #{@expected.inspect}"
      end

      def negative_failure_message
        "Expected #{@target.inspect} not to be the same set as #{@expected.inspect}"
      end
    end

    def be_same_set_as(expected)
      BeSameSetAs.new(expected)
    end
  end


end

