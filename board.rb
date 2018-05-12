class ChessBoard
  def initialize
    @white_pieces = []
    @black_pieces = []
    @count = 0
  end

  # Executes the specified move if legal. Returns true if successful;
  # otherwise returns false.
  def execute_move(move)
    true
  end

  def draw
    print "\nHere's the board\n\n"
  end
  
  def in_check?(side)
    @count += 1
    if side == :white
    else # side == :black
    end
    @count >= 3
  end

  def mate?(side)
    @count >= 4
  end

  # Returns true if not in check and no legal moves
  def stalemate?(side)
  end
end
