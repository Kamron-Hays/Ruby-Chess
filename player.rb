class Player
  attr_accessor :side

  def initialize(side)
    @side = side
  end

  def get_input
    print (@side == :white) ? "White's turn: " : "Black's turn: "
    return gets.strip.downcase
  end
end

class AI_Player < Player
end
