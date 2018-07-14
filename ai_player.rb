class AI_Player < Player
  @@DEBUG = false

  def initialize(side, board)
    @side = side
    @board = board
  end
  
  def get_input
    # Score every possible move, then choose the move with the highest score.
    # If there are multiple moves with the same highest score, randomly choose
    # one.
    #
    # Scoring is done as follows: If the player's piece associated with the
    # move is under attack prior to the move, add the value of the piece. For
    # the remainder of the scoring, a single-move look-ahead is performed. If
    # the move will result in an opponent capture, add the value of the opponent
    # piece. If the move will result in this player's piece being attacked,
    # subtract the piece's value. If under attack both before and after the 
    # move, the score is the negative of the piece value. If the move will
    # result in placing this player's king in check, the score is the negative
    # of the king value.
    best_moves = []
    best_score = nil

    (0..7).each do |x|
      (0..7).each do |y|
        piece = @board.squares[x][y]
        next if piece == nil || piece.side != @side

        print "#{piece}" if @@DEBUG
        piece.get_moves.each do |move|
          score = 0
          attacked_before = false
          opponent_piece = @board.getxy(move)

          if piece.attacked?
            score += piece.value
            attacked_before = true
          end

          if opponent_piece != nil
            score += opponent_piece.value
          end

          board = @board.test_move(move, piece)

          if board.in_check?(@side)
            score = -King.get_value
          elsif board.attacked?(move, @side)
            if attacked_before
              score = -piece.value
            else
              score -= piece.value
            end
          end

          print " #{Board.to_alg(move)}[#{score}]" if @@DEBUG

          if best_score == nil || score >= best_score
            if best_score != nil && score > best_score
                best_moves.clear
            end
            best_moves << [piece.position, move]
            best_score = score
          end
        end
        print "\n" if @@DEBUG
      end
    end

    puts "best_moves=#{best_moves}" if @@DEBUG
    best_move = best_moves.sample
    move = Board.to_alg(best_move[0]) + Board.to_alg(best_move[1])

    side = (@side == :white) ? "White" : "Black"
    puts "#{side}'s move: #{move} "
    move
  end

  def promote(piece)
    # Always choose a queen for pawn promotion.
    Queen.new(nil, @side, nil)
  end
end
