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
end
