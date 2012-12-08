require "spec_helper"

describe Subtle do
  describe "Examples" do
    describe "Project Euler" do
      describe "Problem 1:" +
        " Find the sum of all the multiples of 3 or 5 below 1000." do
        e "+/&~&/!1000%/:3 5", 233168
      end
    end
  end
end
