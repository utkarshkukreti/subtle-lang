module Subtle
  class Transform < Parslet::Transform
    rule(integer: simple(:x)) { x.to_i }
    rule(float:   simple(:x)) { x.to_f }
    rule(array:  subtree(:x)) { x      }

    rule dyad: { left: subtree(:left), verb: simple(:verb),
                 right: subtree(:right) } do
      { type: :dyad, left: left, verb: verb.to_s, right: right }
    end
  end
end
