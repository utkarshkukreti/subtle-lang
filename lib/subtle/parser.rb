module Subtle
  class Parser < Parslet::Parser
    def initialize
      @dyadic_verbs = %w{+ - *  / % ^}
      @dyadic_adverbs = %w{/: \:}
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

    rule :enumerate do
      (str("!") >> spaces? >> (float | integer).as(:last)).as(:enumerate)
    end

    rule(:noun)    { enumerate | array | atom }

    rule :dyadic_verb do
      @dyadic_verbs.map { |verb| str(verb) }.reduce(:|).as(:verb) >> spaces?
    end

    rule :dyadic_adverb do
      @dyadic_adverbs.map { |adverb| str(adverb) }.reduce(:|).as(:adverb) >>
      spaces?
    end

    rule :dyad do
      (noun.as(:left) >> dyadic_verb >> dyadic_adverb.maybe >>
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
