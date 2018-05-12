require_relative "pieces/pawn"
require_relative "pieces/bishop"
require_relative "pieces/knight"
require_relative "pieces/rook"
require_relative "pieces/queen"
require_relative "pieces/king"

class Board
  COL = "     a   b   c   d   e   f   g   h"
  DIV = "   +---+---+---+---+---+---+---+---+"

  attr_accessor :squares, :white_captured, :black_captured

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
    @white_king = King.new("e1", :white, self)

    ('a'..'h').each { |col| Pawn.new(col+'7', :black, self)   }
    %w[a h].each    { |col| Rook.new(col+'8', :black, self)   }
    %w[b g].each    { |col| Knight.new(col+'8', :black, self) }
    %w[c f].each    { |col| Bishop.new(col+'8', :black, self) }
    Queen.new("d8", :black, self)
    @black_king = King.new("e8", :black, self)
  end

  # Performs the specified move for the specified side if legal. Returns true
  # if successful; otherwise returns false.
  def execute_move(move, side)
    message = nil
    status = false

    if !valid_move?(move) || (side != :white && side != :black)
      message = "Invalid move."
      return [status, message]
    end

    x1, y1 = to_xy(move[0..1])
    # Get the piece at the specified start position.
    piece = @squares[x1][y1]

    if !piece
      message = "There is no piece at #{move[0]}#{move[1]}. Try again."
    elsif piece.side == side
      x2, y2 = to_xy(move[2..3])
      # need to check if this is a legal move
      if piece.get_moves.include?([x2,y2])

        if piece.class == King && in_check?([x2,y2], piece.side)
          message = "You cannot move your King into check. Try again."
        else
          target_piece = @squares[x2][y2]

          if target_piece != nil
            captured = (side == :white) ? @black_captured : @white_captured
            captured << target_piece
            @squares[x2][y2] = nil
          end

          @squares[x1][y1] = nil
          @squares[x2][y2] = piece
          piece.moved = true
          piece.position = [x2, y2]
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
  def to_xy(coordinate)
    return nil if coordinate.length != 2
    x = "abcdefgh".index(coordinate[0].downcase)
    y = coordinate[1].to_i - 1
    [x,y]
  end

  # Converts an x,y coordinate into an algebraic coordinate.
  def to_alg(move)
    alg = "#{"abcdefgh"[move[0]]}#{move[1]+1}"
  end

  # Returns the piece (if any) at the specified algebraic coordinate
  # (e.g. c3). Returns nil if no piece is at the coordinate.
  def get(coordinate)
    x,y = to_xy(coordinate)
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
  end

  def valid_move?(move)
    move.match(/[a-h][1-8][a-h][1-8]/)
  end

  # Returns true if square at the specified position and for the specified
  # side is in check by any opponent pieces on the board.
  def in_check?(position, side)
    check = false
    opponent = (side == :white) ? :black : :white

    (0..7).each do |x1|
      (0..7).each do |y1|
        piece = @squares[x1][y1]
        if piece != nil && piece.side == opponent && piece.get_moves.include?(position)
          check = true
        end
      end
      break if check
    end
    check
  end

  # Determines whether the king for the specified side is in check.
  def check?(side)
    king = (side == :white) ? @white_king : @black_king
    in_check?(king.position, side)
  end

  def mate?(side)
    false
  end

  # Returns true if not in check and no legal moves
  def stalemate?(side)
    false
  end
end
