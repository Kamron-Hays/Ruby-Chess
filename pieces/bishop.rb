require_relative "sliding_piece"

class Bishop < SlidingPiece
  def initialize(square, side, board)
    super(square, side, board)
    @name = "Bishop"
    @rules = [[-1,1], [1,1], [-1,-1], [1,-1]]
  end

  def to_s
    side == :white ? "\u2657" : "\u265d"
  end
end
