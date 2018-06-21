require_relative "stepping_piece"

class Knight < SteppingPiece

  @@RULES = [[1,2], [-1,2], [1,-2], [-1,-2], [2,1], [-2,1], [2,-1], [-2,-1]]

  def initialize(square, side, board)
    super(square, side, board)
    @name = "knight"
    @value = 3
  end

  def get_rules
    @@RULES
  end

  def to_s
    side == :white ? "\u2658" : "\u265e"
  end
end