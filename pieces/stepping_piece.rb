require_relative "piece"

class SteppingPiece < Piece
  def get_moves
    moves = []
    x,y = @position
    @rules.each do |rule|
      add_move(moves, x + rule[0], y + rule[1])
    end
    moves
  end
end
