require_relative "sliding_piece"

class Rook < SlidingPiece
  def initialize(square, side, board)
    super(square, side, board)
    @name = "Rook"
    @rules = [[1,0], [0,1], [-1,0], [0,-1]]
  end

  def to_s
    side == :white ? "\u2656" : "\u265c"
  end
end