module Subtle
  class Transform < Parslet::Transform
    rule(integer:    simple(:x)) { x.to_i }
    rule(float:      simple(:x)) { x.to_f }
    rule(array:     subtree(:x)) { x      }

    rule monad: { verb: simple(:verb), right: subtree(:right) } do
      { type: :monad, verb: verb.to_s, right: right }
    end

    rule monad: { verb: simple(:verb), adverb: simple(:adverb),
                  right: subtree(:right) } do
      { type: :monad, verb: verb.to_s, adverb: adverb.to_s, right: right }
    end

    rule dyad: { left: subtree(:left), verb: simple(:verb),
                 right: subtree(:right) } do
      { type: :dyad, left: left, verb: verb.to_s, right: right }
    end

    rule dyad: { left: subtree(:left), verb: simple(:verb),
                 adverb: simple(:adverb), right: subtree(:right) } do
      { type: :dyad, left: left, verb: verb.to_s, adverb: adverb.to_s,
        right: right }
    end

    rule enumerate: { last: subtree(:last) } do
      { type: :enumerate, last: last }
    end

    rule assignment: { identifier: simple(:identifier),
                       right: subtree(:right) } do
      { type: :assignment, identifier: identifier.to_s, right: right }
    end

    rule deassignment: { identifier: simple(:identifier) } do
      { type: :deassignment, identifier: identifier.to_s }
    end

    rule function_call: { function: subtree(:function),
                          right: subtree(:right) } do
      { type: :function_call, function: function, right: right }
    end

    rule function_call: { function: subtree(:function), adverb: simple(:adverb),
                          right: subtree(:right) } do
      { type: :function_call, function: function, adverb: adverb.to_s,
        right: right }
    end
  end
end
