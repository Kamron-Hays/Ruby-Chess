class Piece
  attr_accessor :name, :position, :side, :board, :moved, :attacked, :value

  # Creates a new chess piece.
  # square is an agebraic board coordinate (e.g. c2)
  # size should be either :white or :black
  # board is the Board where the piece will be placed
  def initialize(square, side, board)
    @position = Board.to_xy(square) if square
    @side = side
    @moved = false
    @board = board
    @board.add(self) if board
  end

  # Returns a list of rules that govern relative movement for this piece.
  def get_rules
  end

  def get_moves
  end

  def add_move(moves, x, y)
    status = false

    if @board.in_bounds?(x, y)
      piece = @board.squares[x][y] # is there a piece at the specified location?

      if piece == nil || piece.side != @side
        moves << [x, y]
        status = true
      end
    end
    status
  end

  def attacked?
    @board.attacked?(@position, @side)
  end

  def inspect
    "#{side} #{name} @#{Board.to_alg(position)}"
  end

  def <=>(other)
    @value <=> other.value
  end
end
