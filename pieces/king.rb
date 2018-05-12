require_relative "stepping_piece"

class King < SteppingPiece
  def initialize(square, side, board)
    super(square, side, board)
    @name = "King"
    @rules = [[-1,0], [-1,1], [0,1], [1,1],
              [1,0], [1,-1], [0,-1], [-1,-1]]
  end

  def to_s
    side == :white ? "\u2654" : "\u265a"
  end
end
