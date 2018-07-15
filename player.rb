class Player
  attr_accessor :side

  def initialize(side)
    @side = side
  end

  def get_input(turn)
    side = (@side == :white) ? "White" : "Black"
    print "[#{turn}] #{side}'s turn: "
    # remove all whitespace and convert remaining characters to lower case
    gets.gsub(/\s+/, "").downcase
  end

  # Since pawn promotion is required (i.e. not optional), there should only
  # ever be one pawn at any time on the board that might need to be promoted.
  # A pawn must be promoted to either a queen, rook, bishop, or knight.
  def promote(piece)
    new_piece = nil
    response = nil

    print "Choose a piece for pawn promotion\n" +
      "  q) Queen\n" +
      "  r) Rook\n" +
      "  b) Bishop\n" +
      "  n) Knight\n" +
      "Choice: "

    loop do
      response = gets.chomp.downcase
      break if response == 'q' || response == 'r' || response == 'b' || response == 'n'
      print "Invalid choice. Enter either q, r, b, or n: "
    end
    
    case response
    when 'q'
      new_piece = Queen.new(nil, @side, nil)
    when 'r'
      new_piece = Rook.new(nil, @side, nil)
    when 'b'
      new_piece = Bishop.new(nil, @side, nil)
    when 'n'
      new_piece = Knight.new(nil, @side, nil)
    end

    new_piece
  end
end
