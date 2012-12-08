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

      if Hash === t
        type = t[:type]
        case type
        when :monad
          verb   = t[:verb]
          adverb = t[:adverb]
          right  = try_eval t[:right]

          # `^` in Subtle is `**` in Ruby.
          verb = "**" if verb == "^"

          if adverb
            if Array === right
              if right.size < 2
                ae! t, "Need Array of size atleast 2 for a monadic adverb." +
                  " Your Array had #{right.size} items."
              end
            else
              ae! t, "Can only apply monadic adverb on Arrays." +
                " You passed in #{right.class}."
            end
            case adverb
            when "/"
              right.reduce do |fold, r|
                eval type: :dyad, verb: verb, left: fold, right: r
              end
            end
          else
            if Array === right
            else
              ae! t, "Can only apply monadic verb on Arrays." +
                " You passed in #{right.class}."
            end
            case verb
            when "&"
              [].tap do |ret|
                right.each_with_index do |r, i|
                  r.times { ret << i }
                end
              end
            when "~"
              right.map do |r|
                r == 0 ? 1 : 0
              end
            else
              nie! "Verb #{verb} without Adverb not implemented as a Monad"
            end
          end
        when :dyad
          left   = try_eval t[:left]
          verb   = t[:verb]
          adverb = t[:adverb]
          right  = try_eval t[:right]

          # `^` in Subtle is `**` in Ruby.
          verb = "**" if verb == "^"

          if adverb
            if Array === left && Array === right
            else
              ae! t, "Adverb `#{adverb}` must have arrays on both left and" +
                " right. You passed in #{left.class} and #{right.class}."
            end

            case adverb
            when "/:" # Map each over right
              right.map do |r|
                eval({ type: :dyad, left: left, verb: verb, right: r })
              end
            when "\\:" # Map each over left
              left.map do |l|
                eval({ type: :dyad, left: l, verb: verb, right: right })
              end
            else
              nie! t, "Invalid Adverb #{adverb}"
            end
          else
            case verb
            when "+", "-", "*", "/", "%", "**"
              if Numeric === left && Numeric === right
                left.send(verb, right)
              elsif Array === left && Array === right
                if left.size != right.size
                  ae! t, "Size of left array must be the same as the size of" +
                    " right one, but #{left.size} != #{right.size}."
                end

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
            when "&", "|"
              verb = "min" if verb == "&"
              verb = "max" if verb == "|"

              if Numeric === left && Numeric === right
                [left, right].send(verb)
              elsif Array === left && Array === right
                if left.size != right.size
                  ae! t, "Size of left array must be the same as the size of" +
                    " right one, but #{left.size} != #{right.size}."
                end

                left.zip(right).map do |x, y|
                  [x, y].send(verb)
                end
              elsif Array === left && Numeric === right
                left.map do |l|
                  [l, right].send(verb)
                end
              elsif Numeric === left && Array === right
                right.map do |r|
                  [left, r].send(verb)
                end
              else
                nie! t
              end
            else
              nie! t, "Invalid verb #{verb}."
            end
          end
        when :enumerate
          last = try_eval t[:last]
          if Numeric === last
            (0...last.floor).to_a
          else
            nie! t
          end
        else
          nie! t
        end
      else
        t
      end
    end

    def try_eval(t)
      Hash === t ? eval(t) : t
    end

    def ae!(tree, message = "")
      raise ArgumentError.new message << "\n" << tree.to_yaml
    end

    def nie!(tree, message = "")
      raise NotImplementedError.new message << "\n" << tree.to_yaml
    end
  end
end
