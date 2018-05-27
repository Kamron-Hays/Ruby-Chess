require_relative "pieces/pawn"
require_relative "pieces/bishop"
require_relative "pieces/knight"
require_relative "pieces/rook"
require_relative "pieces/queen"
require_relative "pieces/king"

class Board
  COL = "     a   b   c   d   e   f   g   h"
  DIV = "   +---+---+---+---+---+---+---+---+"

  attr_accessor :squares, :white_captured, :black_captured, :white_king, :black_king

  def initialize
    @squares = Array.new(8) { Array.new(8) }
    @white_captured = []
    @black_captured = []
    @white_king = nil
    @black_king = nil
  end

  def setup
    ('a'..'h').each { |col| Pawn.new(col+'2', :white, self)   }
    %w[a h].each    { |col| Rook.new(col+'1', :white, self)   }
    %w[b g].each    { |col| Knight.new(col+'1', :white, self) }
    %w[c f].each    { |col| Bishop.new(col+'1', :white, self) }
    Queen.new("d1", :white, self)
    King.new("e1", :white, self)

    ('a'..'h').each { |col| Pawn.new(col+'7', :black, self)   }
    %w[a h].each    { |col| Rook.new(col+'8', :black, self)   }
    %w[b g].each    { |col| Knight.new(col+'8', :black, self) }
    %w[c f].each    { |col| Bishop.new(col+'8', :black, self) }
    Queen.new("d8", :black, self)
    King.new("e8", :black, self)
  end

  # Makes a deep copy of this board and all pieces on the board.
  def copy
    board = Board.new
    board.white_king = @white_king
    board.black_king = @black_king

    (0..7).each do |x|
      (0..7).each do |y|
        piece = @squares[x][y]
        next if piece == nil
        new_piece = piece.class.new(Board.to_alg(piece.position), piece.side, board)
        new_piece.moved = piece.moved
        new_piece.attacked = piece.attacked
      end
    end
    board
  end

  # Updates the "attacked" status for the specified piece, as well as any
  # pieces under attack by the specified piece.
  def update_attacks(piece)
    piece.attacked = attacked?(piece.position, piece.side)

    # Mark any opponent pieces that are being attacked by the specified piece
    piece.get_moves.each do |move|
      opponent = get Board.to_alg(move)
      if opponent != nil
        opponent.attacked = true
      end
    end
  end

  def move_piece(piece, x1, y1, x2, y2)
    @squares[x1][y1] = nil
    @squares[x2][y2] = piece
    piece.moved = true
    piece.position = [x2, y2]

    # If the king is castling, the rook needs to be moved also.
    # This is the only instance where more than one piece of the
    # same color moves in a single turn.
    if piece.class == King && (x1-x2).abs > 1
      row = (piece.side == :white) ? 0 : 7
      if [x2, y2] == [6, row] # kingside castle
        move_piece(@squares[7][row], 7, row, 5, row)
      elsif [x2, y2] == [2, row] # queenside castle
        move_piece(@squares[0][row], 0, row, 3, row)
      end
    end

    update_attacks(piece)
  end

  # Performs the specified move for the specified side if legal. Returns true
  # if successful; otherwise returns false.
  def execute_move(move, side)
    if side == :white
      @white_king.check_castle if @white_king
    else
      @black_king.check_castle if @black_king
    end

    move(move, side)
  end

  def move(move, side, testing=false)
    message = nil
    status = false

    if !valid_move?(move) || (side != :white && side != :black)
      message = "Invalid move."
      return [status, message]
    end

    x1, y1 = Board.to_xy(move[0..1])
    # Get the piece at the specified start position.
    piece = @squares[x1][y1]

    if !piece
      message = "There is no piece at #{move[0]}#{move[1]}. Try again."
    elsif piece.side == side
      x2, y2 = Board.to_xy(move[2..3])

      if piece.get_moves.include?([x2,y2])
        if piece.class == King && !testing && test_move([x2,y2], piece)
          message = "You cannot move your king into check. Try again."
        else
          target_piece = @squares[x2][y2]

          if target_piece != nil
            # There is a piece at this square - it's now captured.
            captured = (side == :white) ? @black_captured : @white_captured
            captured << target_piece
            @squares[x2][y2] = nil
          end

          # Update the state of the board and the piece that moved.
          move_piece(piece, x1, y1, x2, y2)
          status = true
        end
      else
        message = "The #{piece.name} at #{move[0]}#{move[1]} cannot legally move to #{move[2]}#{move[3]}. Try again."
      end
    else
      message = "The #{piece.name} at #{move[0]}#{move[1]} is not yours. Try again."
    end
    [status, message]
  end

  def in_bounds?(x, y)
    (x >= 0) && (x <= 7) && (y >= 0) && (y <= 7)
  end

  # Converts a string algebraic coordinate (e.g. c3) into a
  # numeric x,y (zero-based) coordinate (e.g. [2,2].
  def self.to_xy(coordinate)
    return nil if coordinate.length != 2
    x = "abcdefgh".index(coordinate[0].downcase)
    y = coordinate[1].to_i - 1
    [x,y]
  end

  # Converts an x,y coordinate into an algebraic coordinate.
  def self.to_alg(move)
    alg = "#{"abcdefgh"[move[0]]}#{move[1]+1}"
  end

  # Returns the piece (if any) at the specified algebraic coordinate
  # (e.g. c3). Returns nil if no piece is at the coordinate.
  def get(coordinate)
    x,y = Board.to_xy(coordinate)
    @squares[x][y]
  end

  def draw
    puts "\n#{COL}\n#{DIV}\n"

    7.downto(0) do |y|
      row = " #{y+1} "
      (0..7).each { |x| @squares[x][y] ? row += "| #{@squares[x][y]} " : row += "|   " }
      row += "| #{y+1}"
      puts "#{row}\n#{DIV}\n"
    end

    puts "#{COL}\n\n"
  end

  def add(piece)
    x,y = piece.position
    @squares[x][y] = piece
    if piece.class == King
      if piece.side == :white
        @white_king = piece
      else
        @black_king = piece
      end
    end
  end

  def valid_move?(move)
    move.match(/[a-h][1-8][a-h][1-8]/)
  end

  # Returns true if the square at the specified position and for the specified
  # side is under attack by any opponent piece on this board.
  def attacked?(position, side)
    status = false

    if position.class == String
      position = Board.to_xy(position)
    end

    (0..7).each do |x|
      (0..7).each do |y|
        next if [x, y] == position # The position can't attack itself
        piece = @squares[x][y]
        next if piece == nil || piece.side == side # only attacked by opponent

        if piece.get_moves.include?(position)
          status = true
          break
        end
      end
      break if status
    end
    status
  end

  # Determines whether the king for the specified side is in check.
  def in_check?(side)
    king = (side == :white) ? @white_king : @black_king
    king.attacked
  end

  # Executes the move of the specified piece on a separate (and identical)
  # board. Returns true if the associated king is in check after the move.
  # Otherwise, false is returned.
  def test_move(move, piece)
    # make a deep copy so original board state is maintained
    board = self.copy
    start = Board.to_alg(piece.position)
    finish = Board.to_alg(move)
    board.move("#{start}#{finish}", piece.side, true)
    board.in_check?(piece.side)
  end

  # Determines if there are any moves for the specified side that result in
  # the associated king not being in check. If none, a mate condition exists.
  # This will be either a checkmate or stalemate, depending on whether the
  # associated king is currently in check. Returns true if a mate condition
  # exists.
  #
  # The general algorithm is this: proceed to make every legal move that the
  # specified side is allowed to make. If any of those moves result in the
  # associated king not being in check, then it's not mate. This of course
  # needs to be done without affecting the current state of the board.
  def mate?(side)
    status = true

    (0..7).each do |x|
      (0..7).each do |y|
        piece = @squares[x][y]
        next if piece == nil || piece.side != side

        piece.get_moves.each do |move|
          if !test_move(move, piece)
            # found a move where the king is not in check, so no mate
            status = false
            break
          end
        end
      end
      break if !status
    end
    status
  end
end
