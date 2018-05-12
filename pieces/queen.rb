require_relative "sliding_piece"

class Queen < SlidingPiece
  def initialize(square, side, board)
    super(square, side, board)
    @name = "Queen"
    @rules = [[-1,1], [1,1], [-1,-1], [1,-1],
              [1,0], [0,1], [-1,0], [0,-1]]
  end

  def to_s
    side == :white ? "\u2655" : "\u265b"
  end
end
