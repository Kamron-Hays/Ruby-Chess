require_relative "stepping_piece"

class Knight < SteppingPiece
  def initialize(square, side, board)
    super(square, side, board)
    @name = "Knight"
    @rules = [[1,2], [-1,2], [1,-2], [-1,-2],
              [2,1], [-2,1], [2,-1], [-2,-1]]
  end

  def to_s
    side == :white ? "\u2658" : "\u265e"
  end
end