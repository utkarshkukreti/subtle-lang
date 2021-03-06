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
        e "(1; 0 1 1 0 0; 1) & (1; 0 1 0 1 0; 1)", [1, [0, 1, 0, 0, 0], 1]
      end

      describe "on Atoms and Arrays" do
        e "1 | 7 0 & 8 2 | 8 & 6 7 & 1", [7, 1]
        e "1 | (0; 1 0; 0 1 0; (1 0 1 2))", [1, [1, 1], [1, 1, 1], [1, 1, 1, 2]]
        e "(0; 1 0; 0 1 0; (1 0 1 2)) | 1", [1, [1, 1], [1, 1, 1], [1, 1, 1, 2]]
      end
    end

    describe "Rotate (`!`) (on left: Integer, right: Array)" do
      e "2 ! 1 2 3", [3, 1, 2]
      e "2 ! (1 2)", [1, 2]
      e "2 ! (2 3; 4 5; 8)", [8, [2, 3], [4, 5]]
      e "-2 ! 1 2 3", [2, 3, 1]
      e "-2 ! (1 2)", [1, 2]
      e "-2 ! (2 3; 4 5; 8)", [[4, 5], 8, [2, 3]]
    end

    describe "Comparison (`=`, `<`, `>`)" do
      describe "on Atoms" do
        e "1 > 3", 0
        e "7 < 8", 1
        e "7 = 7", 1
      end

      describe "on Arrays" do
        e "1 12 < 7 8", [1, 0]
        e "1 12 > 7 8", [0, 1]
        e "1 12 1 = 7 8 1", [0, 0, 1]
      end

      describe "on Atoms and Arrays" do
        e "1 2 > 3", [0, 0]
        e "7 < 8 0", [1, 0]
        e "7 = 7 7", [1, 1]
      end
    end
  end

  describe "Enumerate (`!`)" do
    describe "Precedence" do
      e "!4", [0, 1, 2, 3]
      e "5 - !2 + 2", [5, 4, 3, 2]
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
        e "&/: 2", [[0, 0]]
        e "&/: 2 1", [[0, 0], [0]]
        e "&/: (0 2; 2 1)", [[1, 1], [0, 0, 1]]

        e "~/: 1", [0]
        e "~/: 0 1", [1, 0]
        e "~/: (0 1; 0 1)", [[1, 0], [1, 0]]

        e "+/: 1", [1]
        e "+/: 1 2 3", [1, 2, 3]
        e "+/: ((1 2; 3 4); (5 6; 7 8))", [[[1, 3], [2, 4]], [[5, 7], [6, 8]]]

        e "|/: 1", [1]
        e "|/: 1 2", [1, 2]
        e "|/: (0 1; 0 2)", [[1, 0], [2, 0]]
      end

      describe "Map over and fold (`//:`)" do
        e "+//: 1", [1]
        e "+//: 1 2", [1, 2]
        e "+//: (1; 2; 3 4)", [1, 2, 7]
        e "+//: (2 4; 3 1)", [6, 4]
        e "+//:+(2 4; 3 1)", [5, 5]
      end

      describe "Scan (`\`)" do
        e "+\\2", [2]
        e "-\\2", [2]
        e "*\\2", [2]
        e "/\\2", [2]
        e "%\\2", [2]
        e "^\\2", [2]

        e "+\\1 2 3 4 5", [1, 3, 6, 10, 15]
        e "-\\1 2 3 4 5", [1, -1, -4, -8, -13]
        e "*\\1 2 3 4 5", [1, 2, 6, 24, 120]
        e "/\\8 4 3 2", [8, 2, 0, 0]
        e "%\\8 6 3 1", [8, 2, 2, 0]
        e "^\\2 1 3 4", [2, 2, 8, 4096]

        e "+\\(1 2; 3 4; 5)", [[1, 2], [4, 6], [9, 11]]
        e "-\\(1 2; 3 4; 5)", [[1, 2], [-2, -2], [-7, -7]]
        e "*\\(1 2; 3 4; 5)", [[1, 2], [3, 8], [15, 40]]
        e "/\\(8 4; 3; 2)", [[8, 4], [2, 1], [1, 0]]
        e "%\\(8 6; 3; 1)", [[8, 6], [2, 0], [0, 0]]
        e "^\\(2 1; 3; 4)", [[2, 1], [8, 1], [4096, 1]]
      end
    end
  end

  describe "Monads" do
    describe "Where (`&`)" do
      e "&1", [0]
      e "&2", [0, 0]
      e "&1 0 1", [0, 2]
      e "&1 3 2", [0, 1, 1, 1, 2, 2]
    end

    describe "Not (`~`)" do
      e "~0", 1
      e "~1", 0
      e "~4", 0
      e "~1 0 -1 1 7 8 0 0", [0, 1, 0, 0, 0, 0, 1, 1]
    end

    describe "Transpose (`+`)" do
      e "+0", 0
      e "+1", 1
      e "+1 2 3", [1, 2, 3]
      e "+(1 2; 3 4; 5 6)", [[1, 3, 5], [2, 4, 6]]
    end

    describe "Reverse (`|`)" do
      e "|1", 1
      e "|1 2", [2, 1]
      e "|(1 2; 3; (6 7; 8))", [[[6, 7], 8], 3, [1, 2]]
    end
  end

  describe "Multi-dimensional Arrays" do
    describe "Declaring" do
      e "(1 2; 3 4; 5 6.6 7)", [[1, 2], [3, 4], [5, 6.6, 7]]
      e "(;;;)", [[], [], [], []]
      e "(;;3 8;)", [[], [], [3, 8], []]
      e "(1;2.2 3.3;(;;3 8;);)", [1, [2.2, 3.3], [[], [], [3, 8], []], []]
    end

    describe "Dyads" do
      describe "on Atoms and 2D/3D Arrays" do
        e "1 + (;1 2; 3 4)", [[], [2, 3], [4, 5]]
        e "(1; 2 3) + 1", [2, [3, 4]]
        e "2 ^ ((5 6; 0 1);1 2; 3 4)", [[[32, 64], [1, 2]], [2, 4], [8, 16]]
        e "(;1 2; 3 4) - 1", [[], [0, 1], [2, 3]]
        e "((5 6; 0 1);1 2; 3 4) ^ 2", [[[25, 36], [0, 1]], [1, 4], [9, 16]]
        e "(1; 2 3; 4 5) + (1; 2 3; 4 5)", [2, [4, 6], [8, 10]]
      end

      describe "on 1D/2D/3D Arrays with 2D/3D Arrays" do
        e "(1 2; 3 4) + (2 3; 4 5)", [[3, 5], [7, 9]]
        e "(1 2; 3 4) % (2 3; 4 5)", [[1, 2], [3, 4]]
        e "(1 2; 3) + (1; 2 3)", [[2, 3], [5, 6]]
        e "((1 2); 5 6) + (3 1)", [[4, 5], [6, 7]]
        e "(((2 4); (6 8)); ((2 4); (6 8))) + 1 2", [[[3, 5], [7, 9]],
                                                     [[4, 6], [8, 10]]]
        e "(((2 4); (6 8)); ((2 4); (6 8))) * (((2 4); (6 8)); ((2 4); (6 8)))",
          [[[4, 16], [36, 64]], [[4, 16], [36, 64]]]
        e "1 2 + (((2 4); (6 8)); ((2 4); (6 8)))", [[[3, 5], [7, 9]],
                                                     [[4, 6], [8, 10]]]
        e "1 2 + ((2; (6 8)); ((2 4 3); 6))", [[3, [7, 9]],
                                                     [[4, 6, 5], 8]]
      end
    end
  end

  describe "Parentheses" do
    e "(1 + 1) * 2", 4
    e "3 + (1 + 1) * 2", 7
    e "(1 + 2) * 3", 9
    e "(((((1 + 1) * 2) + 2) * 3) + 3) * 4", 84
  end

  describe "Variables" do
    @e = Subtle::Evaluator.new
    e "a: 10", 10, @e
    e "a", 10, @e
    e "b", nil, @e
    e "a: 1 + 2", 3, @e
    e "b: a + 2", 5, @e
    # Tests whether dyads are evaluated from right to left.
    e "a: 1", 1, @e
    e "(a: 10) + (b: 6) * a * (a: 3) + a", 82, @e
  end

  describe "Functions" do
    describe "Map" do
      e "{x * 2 - x} 4", -8
      e "{x * 2 - x} 4 6 8", [-8, -24, -48]
      e "{x + 1} {x * 2 - x} 4 6 8", [-7, -23, -47]
      e "{x + {x + x} x} 1 2 3", [3, 6, 9]
      e "{!x} 2", [0, 1]
      e "{!x + 1} 2", [0, 1, 2]
    end

    describe "Map over each right (`/:`)" do
      e "{!x}/:1 2 3", [[0], [0, 1], [0, 1, 2]]
      e "{!x + 1}/:!3", [[0], [0, 1], [0, 1, 2]]
      e "{+x}/:((1 2; 3 4); (4 5; 6 7))", [[[1, 3], [2, 4]], [[4, 6], [5, 7]]]
    end

    describe "Storing in variables" do
      @e = Subtle::Evaluator.new
      e "a: {x + !x}", nil, @e
      e "a 3", [3, 4, 5], @e
      e "a /: 1 2 3", [[1], [2, 3], [3, 4, 5]], @e
      e "b: {x + 1}", nil, @e
      e "c: 4", 4, @e
      e "c: b b b c", 7, @e

      e "d: {x * 2}", nil, @e
      e "e: {2 * d x}", nil, @e
      e "f: {(d x) + e x}", nil, @e
      e "d e f f d e 6", 13824, @e
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

    describe "on Scan adverb" do
      ae! "+\\(1 2; 3; 4 5 6)"
    end
  end
end
