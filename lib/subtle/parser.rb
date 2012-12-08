module Subtle
  class Parser < Parslet::Parser
    def initialize
      @dyadic_verbs = %w{+ - *  / % ^}
    end

    rule(:spaces)  { match["\\s"].repeat(1) }
    rule(:spaces?) { spaces.maybe }
    rule(:digits)  { match["0-9"].repeat(1) }
    rule(:minus)   { str("-") }

    rule(:integer) { (minus.maybe >> digits).as(:integer) >> spaces? }
    rule(:float)   { (minus.maybe >> digits >> str(".") >> digits).as(:float) >>
                     spaces? }
    rule(:atom)    { float | integer }
    rule(:array)   { (atom >> spaces?).repeat(2).as(:array) >> spaces? }
    rule(:noun)    { array | atom }

    rule :dyad do
      (noun.as(:left) >>
       @dyadic_verbs.map { |dyad| str(dyad) }.reduce(:|).as(:verb) >> spaces? >>
       word.as(:right)).as(:dyad)
    end

    rule :word do
      dyad | noun
    end

    rule :sentence do
      word
    end

    root :sentence
  end
end
