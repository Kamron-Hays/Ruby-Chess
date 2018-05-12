class Player
  attr_accessor :side

  def initialize(side)
    @side = side
  end

  def get_input
    print (@side == :white) ? "White's turn: " : "Black's turn: "
    # remove all whitespace and convert remaining characters to lower case
    return gets.gsub(/\s+/, "").downcase
  end
end

class AI_Player < Player
end
