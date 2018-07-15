class AI_Player < Player
  @@DEBUG = false

  def initialize(side, board)
    @side = side
    @board = board
  end
  
  def get_input(turn)
    # Score every possible move, then choose the move with the highest score.
    # If there are multiple moves with the same highest score, randomly choose
    # one. Scoring starts from zero and adds points to encourage movement or
    # takes away points to discourage movement. High value is placed on a move
    # that puts the opponent's king in check (or mate). Lowest value is placed
    # on any move that results in placing this player's king in check.
    best_moves = []
    best_score = nil
    opponent = (@side == :white) ? :black : :white

    (0..7).each do |x|
      (0..7).each do |y|
        piece = @board.squares[x][y]
        next if piece == nil || piece.side != @side

        print "#{piece}" if @@DEBUG
        piece.get_moves.each do |move|
          score = 0

          if piece.attacked?
            # Encourage moving piece out of attack
            score += piece.value
          end

          opponent_piece = @board.getxy(move)
          capture_value = 0
          if opponent_piece != nil
            # Encourage capturing opponent piece
            score += opponent_piece.value
            capture_value = opponent_piece.value
          end

          # Look ahead a single move
          board = @board.test_move(move, piece)

          if board.in_check?(@side)
            # Highly discourage moving into check
            score = -King.get_value
          elsif board.in_check?(opponent)
            if board.mate?(opponent)
              # Highly encourage mating opponent
              score += King.get_value
            else
              if board.attacked?(move, @side)
                # If this player is attacked, will it at least be a good trade?
                score = capture_value - piece.value
              else
                # Highly encourage attacking opponent king without being captured
                score += King.get_value / 2
              end
            end
          elsif board.mate?(opponent)
            # Highly discourage moving into stalemate
            score = -King.get_value + 1
          elsif board.attacked?(move, @side)
            # If this player is attacked, will it at least be a good trade?
            score = capture_value - piece.value
          end

          # Avoid unnecessarily moving the king. Without this, it was observed
          # that a king would often wander into the middle of the board.
          score = -1 if piece.class == King && score == 0

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
    puts "[#{turn}] #{side}'s move: #{move} "
    move
  end

  def promote(piece)
    # Always choose a queen for pawn promotion.
    Queen.new(nil, @side, nil)
  end
end
