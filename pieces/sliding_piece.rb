require_relative "piece"

class SlidingPiece < Piece
  def get_moves
    moves = []

    get_rules.each do |rule|
      x,y = @position

      loop do
        x1 = x + rule[0]
        y1 = y + rule[1]
        # Stop sliding in this direction if we've slid off the board.
        break if !@board.in_bounds?(x1,y1)

        # Add to the list of possible moves if the square
        # is empty or occupied by the opponent's piece.
        if @board.squares[x1][y1] == nil || @board.squares[x1][y1].side != @side
          status = add_move(moves, x + rule[0], y + rule[1])
          x,y = x1,y1
        end

        # Stop sliding in this direction if we hit any piece
        break if @board.squares[x1][y1] != nil
      end
    end
    #moves.each { |move| print "#{@board.to_alg(move)} " }
    moves
  end
end
