require "spec_helper"

describe Subtle::Evaluator do
  describe "Simple Arithmetic" do
    describe "on Atoms" do
      e "1 + 1", 2
      e "1 + 2 - -3 * 8 + 5 % 4", 30
      e "-1 * 5.0 / 4", -1.25
    end

    describe "on Arrays" do
      e "1 1 1 + 2 2 2 * 3 3 3", [7, 7, 7]
    end

    describe "on Atoms and Arrays" do
      e "1.1 1 + -2 + 2 2 * 3 % 4 ^ 2 3 + 1 - -1 -1", [5.1, 5]
    end
  end

  describe "Enumerate (`!`)" do
    describe "Precedence" do
      e "!4", [0, 1, 2, 3]
      e "1 - !2 + 2", [-1, -2]
    end

    describe "on Floats" do
      e "!2.1", [0, 1]
    end
  end

  describe "Adverbs" do
    describe "Map over each right (`/:`)" do
      e "1 2 3 +/: 5 6", [[6, 7, 8], [7, 8, 9]]
      e "1 2 3 -/: 0 1", [[1, 2, 3], [0, 1, 2]]
      e "3 2 3 ^/: 2 3", [[9, 4, 9], [27, 8, 27]]
    end

    describe "Map over each left (`\:`)" do
      e "1 2 3 +\\: 5 6", [[6, 7, 8], [7, 8, 9]].transpose
      e "1 2 3 -\\: 0 1", [[1, 2, 3], [0, 1, 2]].transpose
      e "3 2 3 ^\\: 2 3", [[9, 4, 9], [27, 8, 27]].transpose
    end

    describe "Fold (`/`)" do
      e "+/1 2 3", 6
      # +/3 4 => 7; 1 2 + 7 => 8 9; +/8 9 => 17;
      e "+/1 2 + +/3 4", 17
      e "^/2 3 4", 4096
    end
  end

  describe "Errors" do
    describe "on Arrays" do
      ae! "1 2 + 2 3 4"
    end
  end
end
