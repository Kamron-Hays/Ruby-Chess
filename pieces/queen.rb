require_relative "sliding_piece"

class Queen < SlidingPiece

  @@RULES = [[-1,1], [1,1], [-1,-1], [1,-1], [1,0], [0,1], [-1,0], [0,-1]]

  def initialize(square, side, board)
    super(square, side, board)
    @name = "queen"
    @value = 9
  end

  def get_rules
    @@RULES
  end

  def to_s
    side == :white ? "\u2655" : "\u265b"
  end
end
