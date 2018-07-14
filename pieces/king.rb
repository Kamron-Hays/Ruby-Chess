require_relative "stepping_piece"

class King < SteppingPiece
  attr_accessor :can_castle_kingside, :can_castle_queenside

  @@VALUE = 100
  @@RULES = [[-1,0], [-1,1], [0,1], [1,1], [1,0], [1,-1], [0,-1], [-1,-1]]

  def initialize(square, side, board)
    super(square, side, board)
    @name = "king"
    @value = @@VALUE
  end

  # Determines whether this king can castle.
  # You can't castle if the king or rook has already moved
  # You can't castle if the king is in check, would pass through check, or end in check
  # You can't castle if other pieces are in the way
  def check_castle
    @can_castle_kingside = false
    @can_castle_queenside = false

    if !@moved && !@attacked
      row = (@side == :white) ? "1" : "8"
      # Check kingside castle
      piece = @board.get("h#{row}")
      if piece != nil && piece.class == Rook && piece.side == @side && !piece.moved &&
         @board.get("f#{row}") == nil && @board.get("g#{row}") == nil &&
         !@board.attacked?("f#{row}", @side) && !@board.attacked?("g#{row}", @side)
        @can_castle_kingside = true
      end

      # Check queenside castle
      piece = @board.get("a#{row}")
      if piece != nil && piece.class == Rook && piece.side == @side && !piece.moved &&
         @board.get("b#{row}") == nil && @board.get("c#{row}") == nil && @board.get("d#{row}") == nil &&
         !@board.attacked?("d#{row}", @side) && !@board.attacked?("c#{row}", @side)
        @can_castle_queenside = true
      end
    end
  end

  def get_rules
    @@RULES
  end

  def self.get_value
    @@VALUE
  end

  def get_moves
    moves = super()
    row = (@side == :white) ? "1" : "8"
    moves << Board.to_xy("g#{row}") if @can_castle_kingside
    moves << Board.to_xy("c#{row}") if @can_castle_queenside
    moves
  end

  def to_s
    side == :white ? "\u2654" : "\u265a"
  end
end
