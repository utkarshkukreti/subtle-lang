require "bundler/setup"

require "simplecov"
SimpleCov.start do
  add_group "Libraries", "/lib"
end

require "subtle"

RSpec.configure do |config|
  def e(input, output)
    it "should evaluate #{input.inspect} to #{output.inspect}" do
      evaluator = Subtle::Evaluator.new
      evaluator.eval(input).should eq output
    end
  end
end
