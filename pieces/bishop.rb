require_relative "sliding_piece"

class Bishop < SlidingPiece

  @@RULES = [[-1,1], [1,1], [-1,-1], [1,-1]]

  def initialize(square, side, board)
    super(square, side, board)
    @name = "bishop"
    @value = 3
  end

  def get_rules
    @@RULES
  end

  def to_s
    side == :white ? "\u2657" : "\u265d"
  end
end
