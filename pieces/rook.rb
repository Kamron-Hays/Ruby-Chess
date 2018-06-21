require_relative "sliding_piece"

class Rook < SlidingPiece

  @@RULES = [[1,0], [0,1], [-1,0], [0,-1]]

  def initialize(square, side, board)
    super(square, side, board)
    @name = "rook"
    @value = 5
  end

  def get_rules
    @@RULES
  end

  def to_s
    side == :white ? "\u2656" : "\u265c"
  end
end