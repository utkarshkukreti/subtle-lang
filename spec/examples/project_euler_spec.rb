require "spec_helper"

describe Subtle do
  describe "Examples" do
    describe "Project Euler" do
      describe "Problem 1:" +
        " Find the sum of all the multiples of 3 or 5 below 1000." do
        e "+/&~&/(!1000)%/:3 5", 233168
      end

      describe "Problem 6:" +
        " Find the difference between the sum of the squares of the first" +
        " one hundred natural numbers and the square of the sum." do
        e "((+/!101)^2)-+/(!101)^2", 25164150
      end
    end
  end
end
