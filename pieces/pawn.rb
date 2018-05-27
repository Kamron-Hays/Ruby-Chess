require_relative "stepping_piece"

class Pawn < SteppingPiece
  def initialize(square, side, board)
    super(square, side, board)
    @name = "pawn"
  end

  def get_moves
    moves = []
    blocked = false
    x,y = @position

    # This pawn can only move if a piece is not directly in
    # front of it.
    y1 = ( @side == :white ) ? y + 1 : y - 1
    if @board.squares[x][y1] == nil
      add_move(moves, x, y1)

      # Two steps forward is allowed on first move, but you can't
      # jump over an opponent's piece
      y2 = ( @side == :white ) ? y + 2 : y - 2
      if !@moved && @board.squares[x][y2] == nil
        add_move(moves, x, y2)
      end
    end

    # If there is an opponent's piece at either forward diagonal position,
    # add that position to the list of valid moves.
    if @board.in_bounds?(x-1, y1)
      piece1 = @board.squares[x-1][y1]
      moves << piece1.position if piece1 && (piece1.side != @side)
    end

    if @board.in_bounds?(x+1, y1)
      piece2 = @board.squares[x+1][y1]
      moves << piece2.position if piece2 && (piece2.side != @side)
    end

    #moves.each { |move| print "#{@board.to_alg(move)} " }
    moves
  end

  def to_s
    side == :white ? "\u2659" : "\u265f"
  end
end
