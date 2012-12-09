require "spec_helper"

describe Subtle::Evaluator do
  describe "Dyads" do
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

    describe "And/Min (`&`) and Or/Max(`|`)" do
      describe "on Atoms" do
        e "1 & 2 - 3", -1
        e "7 & 8 | 0", 7
      end

      describe "on Arrays" do
        e "1 12 & 7 8", [1, 8]
        e "1 12 | 7 8", [7, 12]
      end

      describe "on Atoms and Arrays" do
        e "1 | 7 0 & 8 2 | 8 & 6 7 & 1", [7, 1]
      end
    end

    describe "Rotate (`!`) (on left: Integer, right: Array)" do
      e "2 ! 1 2 3", [3, 1, 2]
      e "2 ! (1 2)", [1, 2]
      e "2 ! (2 3; 4 5; 8)", [[8], [2, 3], [4, 5]]
      e "-2 ! 1 2 3", [2, 3, 1]
      e "-2 ! (1 2)", [1, 2]
      e "-2 ! (2 3; 4 5; 8)", [[4, 5], [8], [2, 3]]
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
    describe "on Dyads" do
      describe "Map over each right (`/:`)" do
        e "1 2 3 +/: 5 6", [[6, 7, 8], [7, 8, 9]]
        e "1 2 3 -/: 0 1", [[1, 2, 3], [0, 1, 2]]
        e "3 2 3 ^/: 2 3", [[9, 4, 9], [27, 8, 27]]
        e "3 2 3 &/: 2 3", [[2, 2, 2], [3, 2, 3]]
        e "1 2 3 |/: 0 3", [[1, 2, 3], [3, 3, 3]]
        e "2 !/: (1 2 3; 2 3 4; 4 5 6)", [[3, 1, 2], [4, 2, 3], [6, 4, 5]]
      end

      describe "Map over each left (`\:`)" do
        e "1 2 3 +\\: 5 6", [[6, 7, 8], [7, 8, 9]].transpose
        e "1 2 3 -\\: 0 1", [[1, 2, 3], [0, 1, 2]].transpose
        e "3 2 3 ^\\: 2 3", [[9, 4, 9], [27, 8, 27]].transpose
        e "3 2 3 &\\: 2 3", [[2, 2, 2], [3, 2, 3]].transpose
        e "1 2 3 |\\: 0 3", [[1, 2, 3], [3, 3, 3]].transpose
      end

      describe "Fold (`/`)" do
        e "+/1 2 3", 6
        # +/3 4 => 7; 1 2 + 7 => 8 9; +/8 9 => 17;
        e "+/1 2 + +/3 4", 17
        e "^/2 3 4", 4096
        e "&/1 2 3", 1
        e "|/1 2 3", 3
      end
    end

    describe "on Monads" do
      describe "Map over each right (`/:`)" do
        # Where (`&`), Not (`~`), Transpose (`+`) and Reverse (`|`)
        e "&/: (0 2; 2 1)", [[1, 1], [0, 0, 1]]
        e "~/: (0 1; 0 1)", [[1, 0], [1, 0]]
        e "+/: ((1 2; 3 4); (5 6; 7 8))", [[[1, 3], [2, 4]], [[5, 7], [6, 8]]]
        e "|/: (0 1; 0 2)", [[1, 0], [2, 0]]
      end

      describe "Map over and fold (`//:`)" do
        e "+//: (2 4; 3 1)", [6, 4]
        e "+//:+(2 4; 3 1)", [5, 5]
      end
    end
  end

  describe "Monads" do
    describe "Where (`&`)" do
      e "&1 0 1", [0, 2]
      e "&1 3 2", [0, 1, 1, 1, 2, 2]
    end

    describe "Not (`~`)" do
      e "~1 0 -1 1 7 8 0 0", [0, 1, 0, 0, 0, 0, 1, 1]
    end

    describe "Transpose (`+`)" do
      e "+1 2 3", [1, 2, 3]
      e "+(1 2; 3 4; 5 6)", [[1, 3, 5], [2, 4, 6]]
    end

    describe "Reverse (`|`)" do
      e "|1 2", [2, 1]
      e "|(1 2; 3; (6 7; 8))", [[[6, 7], [8]], [3], [1, 2]]
    end
  end

  describe "Multi-dimensional Arrays" do
    describe "Declaring" do
      e "(1 2; 3 4; 5 6.6 7)", [[1, 2], [3, 4], [5, 6.6, 7]]
      e "(;;;)", [[], [], [], []]
      e "(;;3 8;)", [[], [], [3, 8], []]
      e "(1;2.2 3.3;(;;3 8;);)", [[1], [2.2, 3.3], [[], [], [3, 8], []], []]
    end

    describe "Dyads" do
      describe "on Atoms and 2D/3D Arrays" do
        e "1 + (;1 2; 3 4)", [[], [2, 3], [4, 5]]
        e "2 ^ ((5 6; 0 1);1 2; 3 4)", [[[32, 64], [1, 2]], [2, 4], [8, 16]]
        e "(;1 2; 3 4) - 1", [[], [0, 1], [2, 3]]
        e "((5 6; 0 1);1 2; 3 4) ^ 2", [[[25, 36], [0, 1]], [1, 4], [9, 16]]
      end

      describe "on 1D/2D/3D Arrays with 2D/3D Arrays" do
        e "(1 2; 3 4) + (2 3; 4 5)", [[3, 5], [7, 9]]
        e "(1 2; 3 4) % (2 3; 4 5)", [[1, 2], [3, 4]]
        e "((1 2); 5 6) + (3 1)", [[4, 5], [6, 7]]
        e "(((2 4); (6 8)); ((2 4); (6 8))) + 1 2", [[[3, 5], [7, 9]],
                                                     [[4, 6], [8, 10]]]
        e "(((2 4); (6 8)); ((2 4); (6 8))) * (((2 4); (6 8)); ((2 4); (6 8)))",
          [[[4, 16], [36, 64]], [[4, 16], [36, 64]]]
        e "1 2 + (((2 4); (6 8)); ((2 4); (6 8)))", [[[3, 5], [7, 9]],
                                                     [[4, 6], [8, 10]]]
      end
    end
  end

  describe "Errors" do
    describe "on Arrays" do
      ae! "1 2 + 2 3 4"
      ae! "1 2 | 2 3 4"
    end

    describe "on Rotate" do
      ae! "1 2 ! 2 3"
      ae! "2 ! 1"
    end
  end
end
