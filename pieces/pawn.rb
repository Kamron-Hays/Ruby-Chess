require_relative "stepping_piece"

class Pawn < SteppingPiece
  attr_accessor :en_passant

  def initialize(square, side, board)
    super(square, side, board)
    @name = "pawn"
    @en_passant = false
    @value = 1
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

    # If there is an opponent's pawn on the same row as this piece,
    # and if that pawn has been marked as eligible for en passant
    # capture, add it to the list of valid moves.
    if @board.in_bounds?(x-1, y)
      piece1 = @board.squares[x-1][y]
      moves << [x-1,y1] if piece1 && (piece1.side != @side) && piece1.class == Pawn && piece1.en_passant
    end

    if @board.in_bounds?(x+1, y)
      piece2 = @board.squares[x+1][y]
      moves << [x+1,y1] if piece2 && (piece2.side != @side) && piece2.class == Pawn && piece2.en_passant
    end

    #moves.each { |move| print "#{@board.to_alg(move)} " }
    moves
  end

  def to_s
    side == :white ? "\u2659" : "\u265f"
  end
end
