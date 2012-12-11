module Subtle
  class Evaluator
    def initialize
      @state = {}
      @parser    = Parser.new
      @transform = Transform.new
    end

    def eval(t)
      if String === t
        parsed = @parser.parse t
        t = @transform.apply parsed
      end

      if Hash === t
        type = t[:type]

        case type
        when :assignment
          @state[t[:identifier]] = try_eval t[:right]
        when :deassignment
          @state[t[:identifier]]
        when :function
          t[:function]
        when :function_call
          function = t[:function]
          adverb   = t[:adverb]
          right    = try_eval t[:right]
          if adverb
            case adverb
            when "/:"
              right = [right] unless Array === right
              right.map do |r|
                eval type: :function_call, function: function, right: r
              end
            else
              ae! t, "Invalid adverb #{adverb.inspect} for :function_call."
            end
          else
            _x = @state["x"]
            @state["x"] = right
            eval(function).tap do
              @state["x"] = _x
            end
          end
        when :variable_call
          identifier = t[:identifier]
          adverb     = t[:adverb]
          arguments  = t[:arguments]
          function = @state[identifier]
          eval type: :function_call, function: function, adverb: adverb,
            right: arguments
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
            when "//:"
              right.map do |r|
                eval type: :monad, verb: verb, adverb: "/", right: r
              end
            when "/"
              right.reduce do |fold, r|
                eval type: :dyad, verb: verb, left: fold, right: r
              end
            when "/:" # Map each over right
              right.map do |r|
                eval type: :monad, verb: verb, right: r
              end
            else
              ae! t, "Invalid adverb #{adverb} on Monads."
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
            when "+"
              if Array === right.first
                right.transpose
              else
                right
              end
            when "|"
              right.reverse
            else
              ae! "Verb #{verb} without Adverb not implemented as a Monad"
            end
          end
        when :dyad
          # Evaluate right first.
          right  = try_eval t[:right]
          left   = try_eval t[:left]
          verb   = t[:verb]
          adverb = t[:adverb]

          # `^` in Subtle is `**` in Ruby,
          verb = "**" if verb == "^"
          # `=` is `==`,
          verb = "==" if verb == "="
          # `&` is `min` and `|` is `max.
          verb = "min" if verb == "&"
          verb = "max" if verb == "|"

          if adverb
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
              ae! t, "Invalid Adverb #{adverb}"
            end
          else
            case verb
            when "+", "-", "*", "/", "%", "**", "==", "<", ">"
              if Numeric === left && Numeric === right
                ret = left.send(verb, right)
                if %w{== < >}.include?(verb)
                  ret ? 1 : 0
                else
                  ret
                end
              elsif Array === left && Array === right
                if left.size != right.size
                  ae! t, "Size of left array must be the same as the size of" +
                    " right one, but #{left.size} != #{right.size}."
                end

                left.zip(right).map do |l, r|
                  if Array === l || Array === r
                    eval type: :dyad, verb: verb, left: l, right: r
                  else
                    ret = (try_eval l).send(verb, try_eval(r))
                    if %w{== < >}.include?(verb)
                      ret ? 1 : 0
                    else
                      ret
                    end
                  end
                end
              elsif Array === left && Numeric === right
                left.map do |l|
                  # Multi-dimensional arrays
                  if Array === l
                    eval type: :dyad, verb: verb, left: l, right: right
                  else
                    ret = (try_eval l).send(verb, right)
                    if %w{== < >}.include?(verb)
                      ret ? 1 : 0
                    else
                      ret
                    end
                  end
                end
              elsif Numeric === left && Array === right
                right.map do |r|
                  # Multi-dimensional arrays
                  if Array === r
                    eval type: :dyad, verb: verb, left: left, right: r
                  else
                    ret = left.send(verb, r)
                    if %w{== < >}.include?(verb)
                      ret ? 1 : 0
                    else
                      ret
                    end
                  end
                end
              else
                ae! t, "Left and Array must be Numeric or Arrays." +
                  " You passed in #{left.class} and #{right.class}."
              end
            when "max", "min"
              if Numeric === left && Numeric === right
                [left, right].send(verb)
              elsif Array === left && Array === right
                if left.size != right.size
                  ae! t, "Size of left array must be the same as the size of" +
                    " right one, but #{left.size} != #{right.size}."
                end
                left.zip(right).map do |l, r|
                  eval type: :dyad, verb: verb, left: l, right: r
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
                ae! t
              end
            when "!"
              if Numeric === left && Array === right
              else
                ae! t, "Left must be Numeric and right must be an Array for" +
                  " rotate (`!`) dyad. You passed in #{left.class} and" +
                  " #{right.class}"
              end
              right.rotate(left)
            else
              ae! t, "Invalid verb #{verb}."
            end
          end
        when :enumerate
          last = try_eval t[:last]
          if Numeric === last
            (0...last.floor).to_a
          else
            ae! t, "`last` must be Numeric for type: :enumerate. You passed" +
              " in #{last.class}."
          end
        else
          ae! t, "Type #{t[:type].inspect} not implemented."
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
  end
end
