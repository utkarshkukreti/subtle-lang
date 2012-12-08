module Subtle
  class Evaluator
    def initialize
      @parser    = Parser.new
      @transform = Transform.new
    end

    def eval(string_or_tree)
      if String === string_or_tree
        parsed = @parser.parse string_or_tree
        t = @transform.apply parsed
      else
        t = string_or_tree
      end

      type = t[:type]
      case type
      when :dyad
        left  = try_eval t[:left]
        verb  = t[:verb]
        right = try_eval t[:right]

        # `^` in Subtle is `**` in Ruby.
        verb = "**" if verb == "^"

        case verb
        when "+", "-", "*", "/", "%", "**"
          if Numeric === left && Numeric === right
            left.send(verb, right)
          elsif Array === left && Array === right
            left.zip(right).map do |x, y|
              x.send(verb, y)
            end
          elsif Array === left && Numeric === right
            left.map do |l|
              l.send(verb, right)
            end
          elsif Numeric === left && Array === right
            right.map do |r|
              left.send(verb, r)
            end
          else
            nie! t
          end
        end
      else
        nie! t
      end
    end

    def try_eval(t)
      Hash === t ? eval(t) : t
    end

    def nie!(tree)
      raise NotImplementedError.new tree.to_yaml
    end
  end
end
