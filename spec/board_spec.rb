require_relative "spec_helper"
require_relative "../board"

describe Board do

  # The 'subject' variable will automatically be initialized with a new Board
  # object prior to each test case.

  describe "#execute_move(move, side)" do

    it "Can't move a non-existent piece" do
      status, message = subject.execute_move("b1b2", :white)
      expect(status).to be false
      expect(message).to eql "There is no piece at b1."
    end

    it "Can't move opponent's piece" do
      piece = Pawn.new("b1", :black, subject)
      status, message = subject.execute_move("b1b2", :white)
      expect(status).to be false
      expect(message).to eql "The pawn at b1 is not yours."
    end

    it "Can't move to friendly occupied square" do
      piece1 = Pawn.new("b1", :white, subject)
      piece2 = Knight.new("b2", :white, subject)
      status, message = subject.execute_move("b1b2", :white)
      expect(status).to be false
      expect(message).to eql "The pawn at b1 cannot legally move to b2."
    end

    it "Handles invalid movement commands" do
      piece = Rook.new("b1", :black, subject)
      status, message = subject.execute_move("i1i2", :white)
      expect(status).to be false
      status, message = subject.execute_move("b1b9", :white)
      expect(status).to be false
      status, message = subject.execute_move("garbage", :white)
      expect(status).to be false
      status, message = subject.execute_move("b1b2", :yellow)
      expect(status).to be false
    end

    it "Cannot make a move that places one's king in check" do
      King.new("e1", :white, subject)
      Rook.new("e4", :white, subject)
      Queen.new("e8", :black, subject)
      status, message = subject.execute_move("e4f4", :white)
      expect(status).to be false
    end

    #######################
    # Test pawn movements #
    #######################

    context "Given a pawn" do

      it "Can move one space forward" do
        piece = Pawn.new("b1", :white, subject)
        status, message = subject.execute_move("b1b2", :white)
        expect(status).to be true
        expect(subject.get("b1")).to be nil
        expect(subject.get("b2")).to be piece
        piece = Pawn.new("h8", :black, subject)
        status, message = subject.execute_move("h8h7", :black)
        expect(status).to be true
      end

      it "Can move two spaces forward on first move only" do
        piece = Pawn.new("b1", :white, subject)
        status, message = subject.execute_move("b1b3", :white)
        expect(status).to be true
        expect(subject.get("b1")).to be nil
        expect(subject.get("b3")).to be piece
        status, message = subject.execute_move("b3b5", :white)
        expect(status).to be false
        expect(message).to eql "The pawn at b3 cannot legally move to b5."
        expect(subject.get("b5")).to be nil
        expect(subject.get("b3")).to be piece
        piece = Pawn.new("g7", :black, subject)
        status, message = subject.execute_move("g7g5", :black)
        expect(status).to be true
        status, message = subject.execute_move("g5g3", :black)
        expect(status).to be false
      end

      it "Can't move backward, laterally, or diagonally" do
        piece = Pawn.new("b2", :white, subject)
        status, message = subject.execute_move("b2b1", :white)
        expect(status).to be false
        expect(message).to eql "The pawn at b2 cannot legally move to b1."
        status, message = subject.execute_move("b2a1", :white)
        expect(status).to be false
        expect(message).to eql "The pawn at b2 cannot legally move to a1."
        status, message = subject.execute_move("b2a2", :white)
        expect(status).to be false
        expect(message).to eql "The pawn at b2 cannot legally move to a2."
        status, message = subject.execute_move("b2c1", :white)
        expect(status).to be false
        expect(message).to eql "The pawn at b2 cannot legally move to c1."
        status, message = subject.execute_move("b2c2", :white)
        expect(status).to be false
        expect(message).to eql "The pawn at b2 cannot legally move to c2."
        status, message = subject.execute_move("b2c3", :white)
        expect(status).to be false
        expect(message).to eql "The pawn at b2 cannot legally move to c3."
        status, message = subject.execute_move("b2a3", :white)
        expect(status).to be false
        expect(message).to eql "The pawn at b2 cannot legally move to a3."
        expect(subject.get("b2")).to be piece
      end

      it "Can diagonally capture opponent's pawn" do
        piece1 = Pawn.new("b1", :white, subject)
        piece2 = Pawn.new("a2", :black, subject)
        status, message = subject.execute_move("b1a2", :white)
        expect(status).to be true
        expect(subject.get("b1")).to be nil
        expect(subject.get("a2")).to be piece1
        expect(subject.black_captured[0]).to be piece2
      end

      it "Can't move forward if blocked by another piece" do
        Pawn.new("d3", :white, subject)
        Pawn.new("d4", :black, subject)
        status, message = subject.execute_move("d3d4", :white)
        expect(status).to be false
        status, message = subject.execute_move("d3d5", :white)
        expect(status).to be false
        Pawn.new("h6", :black, subject)
        Pawn.new("h5", :white, subject)
        status, message = subject.execute_move("h6h5", :black)
        expect(status).to be false
        status, message = subject.execute_move("h6h4", :black)
      end

      it "Can capture en passant" do
        Pawn.new("d2", :white, subject)
        piece1 = Pawn.new("c4", :black, subject)
        Pawn.new("e7", :black, subject)
        piece2 = Pawn.new("d5", :white, subject)
        status, message = subject.execute_move("d2d4", :white)
        expect(status).to be true
        status, message = subject.execute_move("c4d3", :black)
        expect(status).to be true
        expect(subject.get("d3")).to be piece1
        expect(subject.get("d4")).to be nil
        status, message = subject.execute_move("e7e5", :black)
        expect(status).to be true
        status, message = subject.execute_move("d5e6", :white)
        expect(status).to be true
        expect(subject.get("e6")).to be piece2
        expect(subject.get("e5")).to be nil
      end
    end

    #########################
    # Test knight movements #
    #########################

    context "Given a knight" do
      it "Follows knight movement rules" do
        piece = Knight.new("e4", :white, subject)
        status, message = subject.execute_move("e4d6", :white)
        expect(status).to be true
        status, message = subject.execute_move("d6e4", :white)
        expect(status).to be true
        status, message = subject.execute_move("e4c5", :white)
        expect(status).to be true
        status, message = subject.execute_move("c5e4", :white)
        expect(status).to be true
        status, message = subject.execute_move("e4g5", :white)
        expect(status).to be true
        status, message = subject.execute_move("g5e4", :white)
        expect(status).to be true
        status, message = subject.execute_move("e4f6", :white)
        expect(status).to be true
        status, message = subject.execute_move("f6e4", :white)
        expect(status).to be true
        status, message = subject.execute_move("e4e5", :white)
        expect(status).to be false
        status, message = subject.execute_move("e4d5", :white)
        expect(status).to be false
      end

      it "Is able to jump over other pieces" do
        knight = Knight.new("e4", :white, subject)
        queen = Queen.new("e5", :black, subject)
        pawn = Pawn.new("d5", :black, subject)
        status, message = subject.execute_move("e4c5", :white)
        expect(status).to be true
      end

      it "Can capture opponent pieces" do
        knight = Knight.new("e4", :white, subject)
        queen = Queen.new("c5", :black, subject)
        status, message = subject.execute_move("e4c5", :white)
        expect(subject.black_captured[0]).to be queen
      end
    end

    #########################
    # Test bishop movements #
    #########################

    context "Given a bishop" do
      it "Can move diagonally" do
        piece = Bishop.new("d4", :white, subject)
        status, message = subject.execute_move("d4a7", :white)
        expect(status).to be true
        status, message = subject.execute_move("a7d4", :white)
        expect(status).to be true
        status, message = subject.execute_move("d4h8", :white)
        expect(status).to be true
        status, message = subject.execute_move("h8d4", :white)
        expect(status).to be true
        status, message = subject.execute_move("d4a1", :white)
        expect(status).to be true
        status, message = subject.execute_move("a1d4", :white)
        expect(status).to be true
        status, message = subject.execute_move("d4g1", :white)
        expect(status).to be true
        status, message = subject.execute_move("g1d4", :white)
        expect(status).to be true
      end

      it "Can't move horizontally or vertically" do
        piece = Bishop.new("d5", :white, subject)
        status, message = subject.execute_move("d5c5", :white)
        expect(status).to be false
        status, message = subject.execute_move("d5d6", :white)
        expect(status).to be false
        status, message = subject.execute_move("d5e5", :white)
        expect(status).to be false
        status, message = subject.execute_move("d5d4", :white)
        expect(status).to be false
      end

      it "Can't jump pieces when sliding" do
        piece = Bishop.new("a1", :black, subject)
        pawn = Pawn.new("g7", :black, subject)
        status, message = subject.execute_move("a1h8", :black)
        expect(status).to be false
        status, message = subject.execute_move("a1g7", :black)
        expect(status).to be false
        status, message = subject.execute_move("a1f6", :black)
        expect(status).to be true
      end

      it "Can slide to capture opponent's piece" do
        piece = Bishop.new("f2", :black, subject)
        queen = Queen.new("b6", :white, subject)
        status, message = subject.execute_move("f2b6", :black)
        expect(status).to be true
        expect(subject.white_captured[0]).to be queen
      end

      it "Can't slide past opponent's piece" do
        piece = Bishop.new("f2", :white, subject)
        queen = Queen.new("b6", :black, subject)
        status, message = subject.execute_move("f2a7", :white)
        expect(status).to be false
      end
    end

    #######################
    # Test rook movements #
    #######################

    context "Given a rook" do
      it "Can move horizontally and vertically" do
        piece = Rook.new("d5", :white, subject)
        status, message = subject.execute_move("d5d8", :white)
        expect(status).to be true
        status, message = subject.execute_move("d8d1", :white)
        expect(status).to be true
        status, message = subject.execute_move("d1d4", :white)
        expect(status).to be true
        status, message = subject.execute_move("d4a4", :white)
        expect(status).to be true
        status, message = subject.execute_move("a4h4", :white)
        expect(status).to be true
        status, message = subject.execute_move("h4f4", :white)
        expect(status).to be true
      end

      it "Must stop sliding when it runs into friendly piece" do
        piece = Rook.new("a3", :black, subject)
        pawn = Pawn.new("h3", :black, subject)
        status, message = subject.execute_move("a3h3", :black)
        expect(status).to be false
        status, message = subject.execute_move("a3g3", :black)
        expect(status).to be true
      end

      it "Can slide to capture opponent's piece" do
        piece = Rook.new("b1", :black, subject)
        queen = Queen.new("b7", :white, subject)
        status, message = subject.execute_move("b1b7", :black)
        expect(status).to be true
        expect(subject.white_captured[0]).to be queen
      end

      it "Can't slide past opponent's piece" do
        piece = Rook.new("e8", :white, subject)
        queen = Queen.new("e2", :black, subject)
        status, message = subject.execute_move("e8e1", :white)
        expect(status).to be false
      end

      it "Can't move diagonally" do
        piece = Rook.new("f6", :white, subject)
        status, message = subject.execute_move("f6e5", :white)
        expect(status).to be false
        status, message = subject.execute_move("f6e7", :white)
        expect(status).to be false
        status, message = subject.execute_move("f6g7", :white)
        expect(status).to be false
        status, message = subject.execute_move("f6g5", :white)
        expect(status).to be false
      end
    end

    ########################
    # Test Queen movements #
    ########################

    context "Given a queen" do
      it "Can slide in any direction" do
        piece = Queen.new("d5", :white, subject)
        status, message = subject.execute_move("d5a5", :white)
        expect(status).to be true
        status, message = subject.execute_move("a5d5", :white)
        expect(status).to be true
        status, message = subject.execute_move("d5a8", :white)
        expect(status).to be true
        status, message = subject.execute_move("a8d5", :white)
        expect(status).to be true
        status, message = subject.execute_move("d5d8", :white)
        expect(status).to be true
        status, message = subject.execute_move("d8d5", :white)
        expect(status).to be true
        status, message = subject.execute_move("d5g8", :white)
        expect(status).to be true
        status, message = subject.execute_move("g8d5", :white)
        expect(status).to be true
        status, message = subject.execute_move("d5h5", :white)
        expect(status).to be true
        status, message = subject.execute_move("h5d5", :white)
        expect(status).to be true
        status, message = subject.execute_move("d5h1", :white)
        expect(status).to be true
        status, message = subject.execute_move("h1d5", :white)
        expect(status).to be true
        status, message = subject.execute_move("d5d1", :white)
        expect(status).to be true
        status, message = subject.execute_move("d1d5", :white)
        expect(status).to be true
      end

      it "Can't jump pieces when sliding" do
        piece = Queen.new("a1", :black, subject)
        pawn = Pawn.new("g7", :black, subject)
        status, message = subject.execute_move("a1h8", :black)
        expect(status).to be false
        status, message = subject.execute_move("a1g7", :black)
        expect(status).to be false
        status, message = subject.execute_move("a1f6", :black)
        expect(status).to be true
      end

      it "Can slide to capture opponent's piece" do
        piece = Queen.new("f2", :black, subject)
        queen = Queen.new("b6", :white, subject)
        status, message = subject.execute_move("f2b6", :black)
        expect(status).to be true
        expect(subject.white_captured[0]).to be queen
      end

      it "Can't slide past opponent's piece" do
        piece = Queen.new("f2", :white, subject)
        queen = Queen.new("b6", :black, subject)
        status, message = subject.execute_move("f2a7", :white)
        expect(status).to be false
      end
    end

    #######################
    # Test King movements #
    #######################

    context "Given a king" do

      it "Can move one square in all directions" do
        king = King.new("c4", :white, subject)
        status, message = subject.execute_move("c4c5", :white)
        expect(status).to be true
        expect(subject.get("c4")).to be nil
        expect(subject.get("c5")).to be king
        status, message = subject.execute_move("c5c4", :white)
        expect(status).to be true
        status, message = subject.execute_move("c4b4", :white)
        expect(status).to be true
        status, message = subject.execute_move("b4c4", :white)
        expect(status).to be true
        status, message = subject.execute_move("c4b5", :white)
        expect(status).to be true
        status, message = subject.execute_move("b5c4", :white)
        expect(status).to be true
        status, message = subject.execute_move("c4d3", :white)
        expect(status).to be true
        status, message = subject.execute_move("d3c4", :white)
        expect(status).to be true
        expect(subject.get("c4")).to be king
      end

      it "Can't move further than one square" do
        king = King.new("g6", :black, subject)
        status, message = subject.execute_move("g6g4", :black)
        expect(status).to be false
        expect(subject.get("g6")).to be king
        expect(subject.get("g4")).to be nil
      end

      it "Can't move into check" do
        King.new("e1", :white, subject)
        Queen.new("f3", :black, subject)
        status, message = subject.execute_move("e1e2", :white)
        expect(status).to be false
        expect(message).to eql "You cannot move your king into check."
      end

      it "Can castle kingside" do
        wking = King.new("e1", :white, subject)
        wrook = Rook.new("h1", :white, subject)
        Pawn.new("e2", :white, subject)
        Pawn.new("f2", :white, subject)
        Pawn.new("g2", :white, subject)
        Pawn.new("h2", :white, subject)
        bking = King.new("e8", :black, subject)
        brook = Rook.new("h8", :black, subject)
        Pawn.new("e7", :black, subject)
        Pawn.new("f7", :black, subject)
        Pawn.new("g7", :black, subject)
        Pawn.new("h7", :black, subject)
        status, message = subject.execute_move("e1g1", :white)
        expect(status).to be true
        expect(subject.get("g1")).to be wking
        expect(subject.get("f1")).to be wrook
        expect(subject.get("e1")).to be nil
        expect(subject.get("h1")).to be nil
        status, message = subject.execute_move("e8g8", :black)
        expect(status).to be true
        expect(subject.get("g8")).to be bking
        expect(subject.get("f8")).to be brook
        expect(subject.get("e8")).to be nil
        expect(subject.get("h8")).to be nil
      end

      it "Can castle queenside" do
        wking = King.new("e1", :white, subject)
        wrook = Rook.new("a1", :white, subject)
        Pawn.new("a2", :white, subject)
        Pawn.new("b2", :white, subject)
        Pawn.new("c2", :white, subject)
        Pawn.new("d2", :white, subject)
        Pawn.new("e2", :white, subject)
        bking = King.new("e8", :black, subject)
        brook = Rook.new("a8", :black, subject)
        Pawn.new("a7", :black, subject)
        Pawn.new("b7", :black, subject)
        Pawn.new("c7", :black, subject)
        Pawn.new("d7", :black, subject)
        Pawn.new("e7", :black, subject)
        status, message = subject.execute_move("e1c1", :white)
        expect(status).to be true
        expect(subject.get("c1")).to be wking
        expect(subject.get("d1")).to be wrook
        expect(subject.get("e1")).to be nil
        expect(subject.get("a1")).to be nil
        status, message = subject.execute_move("e8c8", :black)
        expect(status).to be true
        expect(subject.get("c8")).to be bking
        expect(subject.get("d8")).to be brook
        expect(subject.get("e8")).to be nil
        expect(subject.get("a8")).to be nil
      end

      it "Can't castle if the king has already moved" do
        King.new("e1", :white, subject)
        Rook.new("a1", :white, subject)
        Rook.new("h1", :white, subject)
        subject.execute_move("e1e2", :white)
        subject.execute_move("e2e1", :white)
        status, message = subject.execute_move("e1c1", :white)
        expect(status).to be false
        status, message = subject.execute_move("e1g1", :white)
        expect(status).to be false
      end

      it "Can't castle if the rook has already moved" do
        King.new("e1", :white, subject)
        Rook.new("a1", :white, subject)
        Rook.new("h1", :white, subject)
        subject.execute_move("a1a2", :white)
        subject.execute_move("a2a1", :white)
        subject.execute_move("h1h2", :white)
        subject.execute_move("h2h1", :white)
        status, message = subject.execute_move("e1c1", :white)
        expect(status).to be false
        status, message = subject.execute_move("e1g1", :white)
        expect(status).to be false
      end

      it "Can't castle if in check" do
        King.new("e1", :white, subject)
        Rook.new("a1", :white, subject)
        Rook.new("h1", :white, subject)
        Knight.new("d3", :black, subject)
        status, message = subject.execute_move("e1c1", :white)
        expect(status).to be false
        status, message = subject.execute_move("e1g1", :white)
        expect(status).to be false
      end

      it "Can't castle if moves through check" do
        King.new("e1", :white, subject)
        Rook.new("a1", :white, subject)
        Rook.new("h1", :white, subject)
        Rook.new("f3", :black, subject)
        Rook.new("d3", :black, subject)
        status, message = subject.execute_move("e1c1", :white)
        expect(status).to be false
        status, message = subject.execute_move("e1g1", :white)
        expect(status).to be false
      end

      it "Can't castle if ends in check" do
        King.new("e1", :white, subject)
        Rook.new("a1", :white, subject)
        Rook.new("h1", :white, subject)
        Bishop.new("e3", :black, subject)
        status, message = subject.execute_move("e1c1", :white)
        expect(status).to be false
        status, message = subject.execute_move("e1g1", :white)
        expect(status).to be false
      end

      it "Can't castle if a piece is in the way" do
        King.new("e1", :white, subject)
        Rook.new("a1", :white, subject)
        Rook.new("h1", :white, subject)
        Bishop.new("b1", :white, subject)
        Pawn.new("g1", :black, subject)
        status, message = subject.execute_move("e1c1", :white)
        expect(status).to be false
        status, message = subject.execute_move("e1g1", :white)
        expect(status).to be false
      end

      it "Can't castle with opponent's rook" do
        King.new("e1", :white, subject)
        Rook.new("a1", :black, subject)
        Rook.new("h1", :black, subject)
        status, message = subject.execute_move("e1c1", :white)
        expect(status).to be false
        status, message = subject.execute_move("e1g1", :white)
        expect(status).to be false
      end
    end
  end

  describe "#in_check?(side) and #mate?(side)" do

    it "Must move out of check if possible case #1" do
      King.new("e1", :white, subject)
      Knight.new("d3", :white, subject)
      Queen.new("f2", :black, subject)
      expect(subject.in_check?(:white)).to be true
      status, message = subject.execute_move("d3e5", :white)
      expect(status).to be false
      expect(message).to eql "You must move out of check."
      # King moves away from check
      status, message = subject.execute_move("e1d1", :white)
      expect(status).to be true
    end

    it "Must move out of check if possible case #2" do
      King.new("e1", :white, subject)
      Knight.new("d3", :white, subject)
      Queen.new("f2", :black, subject)
      expect(subject.in_check?(:white)).to be true
      # King captures the piece that placed it in check
      status, message = subject.execute_move("e1f2", :white)
      expect(status).to be true
    end

    it "Must move out of check if possible case #3" do
      King.new("e1", :white, subject)
      Knight.new("d3", :white, subject)
      Queen.new("f2", :black, subject)
      expect(subject.in_check?(:white)).to be true
      # The King moves, but is still in check
      status, message = subject.execute_move("e1e2", :white)
      expect(status).to be false
      expect(message).to eql "You must move out of check."
      # Another piece captures the piece that placed the king in check
      status, message = subject.execute_move("d3f2", :white)
      expect(status).to be true
      expect(message).to be nil
    end

    it "Properly detects Fool's Mate" do
      subject.setup
      expect(subject.in_check?(:black)).to be false
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:black)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("f2f3", :white)
      expect(subject.in_check?(:black)).to be false
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:black)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("e7e6", :black)
      expect(subject.in_check?(:black)).to be false
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:black)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("g2g4", :white)
      expect(subject.in_check?(:black)).to be false
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:black)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("d8h4", :black)
      expect(subject.in_check?(:black)).to be false
      expect(subject.in_check?(:white)).to be true
      expect(subject.mate?(:black)).to be false
      expect(subject.mate?(:white)).to be true
    end

    it "Properly detects checkmate with two rooks" do
      King.new("d8", :black, subject)
      King.new("c2", :white, subject)
      Rook.new("a7", :white, subject)
      Rook.new("h1", :white, subject)
      expect(subject.in_check?(:black)).to be false
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:black)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("h1h8", :white)
      expect(subject.in_check?(:black)).to be true
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:black)).to be true
      expect(subject.mate?(:white)).to be false
    end

    it "Properly detects checkmate with queen guarded by king" do
      King.new("h6", :black, subject)
      King.new("f5", :white, subject)
      Queen.new("e8", :white, subject)
      expect(subject.in_check?(:black)).to be false
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:black)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("e8g6", :white)
      expect(subject.in_check?(:black)).to be true
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:black)).to be true
      expect(subject.mate?(:white)).to be false
    end

    it "Properly detects stalemate" do
      King.new("h8", :black, subject)
      King.new("d2", :white, subject)
      Queen.new("e6", :white, subject)
      expect(subject.in_check?(:black)).to be false
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:black)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("e6f7", :white)
      expect(subject.in_check?(:black)).to be false
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:black)).to be true
      expect(subject.mate?(:white)).to be false
    end
  end

  describe "General game play" do

    it "Successfully completes game pattern #1" do
      subject.setup
      subject.execute_move("e2e3", :white)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("e7e6", :black)
      expect(subject.in_check?(:black)).to be false
      expect(subject.mate?(:black)).to be false
      subject.execute_move("f1d3", :white)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("f8d6", :black)
      expect(subject.in_check?(:black)).to be false
      expect(subject.mate?(:black)).to be false
      subject.execute_move("g1h3", :white)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("g8h6", :black)
      expect(subject.in_check?(:black)).to be false
      expect(subject.mate?(:black)).to be false
      subject.execute_move("e1g1", :white)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("e8g8", :black)
      expect(subject.in_check?(:black)).to be false
      expect(subject.mate?(:black)).to be false
    end

    it "Successfully completes game pattern #2" do
      subject.setup
      subject.execute_move("e2e4", :white)
      expect(subject.in_check?(:black)).to be false
      expect(subject.mate?(:black)).to be false
      subject.execute_move("c7c5", :black)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("g1f3", :white)
      expect(subject.in_check?(:black)).to be false
      expect(subject.mate?(:black)).to be false
      subject.execute_move("b8b6", :black)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("d2d4", :white)
      expect(subject.in_check?(:black)).to be false
      expect(subject.mate?(:black)).to be false
      subject.execute_move("c5d4", :black)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      expect(subject.white_captured.size).to eq 1
      subject.execute_move("f3d4", :white)
      expect(subject.in_check?(:black)).to be false
      expect(subject.mate?(:black)).to be false
      expect(subject.black_captured.size).to eq 1
      subject.execute_move("g7g6", :black)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("b1c3", :white)
      expect(subject.in_check?(:black)).to be false
      expect(subject.mate?(:black)).to be false
      subject.execute_move("f8g7", :black)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("c1e3", :white)
      expect(subject.in_check?(:black)).to be false
      expect(subject.mate?(:black)).to be false
      subject.execute_move("g8f6", :black)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("f1c4", :white)
      expect(subject.in_check?(:black)).to be false
      expect(subject.mate?(:black)).to be false
      subject.execute_move("e8g8", :black)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("c4b3", :white)
      expect(subject.in_check?(:black)).to be false
      expect(subject.mate?(:black)).to be false
      subject.execute_move("c6a5", :black)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("e4e5", :white)
      expect(subject.in_check?(:black)).to be false
      expect(subject.mate?(:black)).to be false
      subject.execute_move("f6e8", :black)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("b3f7", :white)
      expect(subject.in_check?(:black)).to be true
      expect(subject.mate?(:black)).to be false
      expect(subject.black_captured.size).to eq 2
      subject.execute_move("g8f7", :black)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      expect(subject.white_captured.size).to eq 2
      subject.execute_move("d4e6", :white)
      expect(subject.in_check?(:black)).to be false
      expect(subject.mate?(:black)).to be false
      subject.execute_move("f7e6", :black)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      expect(subject.white_captured.size).to eq 3
      subject.execute_move("d1d5", :white)
      expect(subject.in_check?(:black)).to be true
      expect(subject.mate?(:black)).to be false
      subject.execute_move("e6f5", :black)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("g2g4", :white)
      expect(subject.in_check?(:black)).to be true
      expect(subject.mate?(:black)).to be false
      subject.execute_move("f5g4", :black)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      expect(subject.white_captured.size).to eq 4
      subject.execute_move("h1g1", :white)
      expect(subject.in_check?(:black)).to be true
      expect(subject.mate?(:black)).to be false
      subject.execute_move("g4h3", :black)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("d5g2", :white)
      expect(subject.in_check?(:black)).to be true
      expect(subject.mate?(:black)).to be false
      subject.execute_move("h3h4", :black)
      expect(subject.in_check?(:white)).to be false
      expect(subject.mate?(:white)).to be false
      subject.execute_move("g2g4", :white)
      expect(subject.in_check?(:black)).to be true
      expect(subject.mate?(:black)).to be true
    end
  end

  describe "#promote? and #promote(pawn, new_piece)" do

    it "Properly detects when a pawn should be promoted" do
      subject.setup
      w_queen = Queen.new(nil, :white, nil)
      b_rook = Rook.new(nil, :black, nil)
      subject.execute_move("d2d4", :white)
      expect(subject.promote?).to be nil
      subject.execute_move("c7c5", :black)
      expect(subject.promote?).to be nil
      subject.execute_move("d4c5", :white)
      expect(subject.promote?).to be nil
      subject.execute_move("b7b5", :black)
      expect(subject.promote?).to be nil
      subject.execute_move("c5c6", :white)
      expect(subject.promote?).to be nil
      subject.execute_move("c8b7", :black)
      expect(subject.promote?).to be nil
      subject.execute_move("c6c7", :white)
      expect(subject.promote?).to be nil
      subject.execute_move("b5b4", :black)
      expect(subject.promote?).to be nil
      subject.execute_move("c7c8", :white)
      pawn = subject.promote?
      expect(pawn.class).to be Pawn
      expect(pawn.side).to be :white
      expect(subject.promote(pawn, w_queen)).to be true
      subject.execute_move("b4b3", :black)
      expect(subject.promote?).to be nil
      subject.execute_move("c1d2", :white)
      expect(subject.promote?).to be nil
      subject.execute_move("b3c2", :black)
      expect(subject.promote?).to be nil
      subject.execute_move("d2e3", :white)
      expect(subject.promote?).to be nil
      subject.execute_move("c2c1", :black)
      pawn = subject.promote?
      expect(pawn.class).to be Pawn
      expect(pawn.side).to be :black
      expect(subject.promote(pawn, w_queen)).to be false
      expect(subject.promote(pawn, nil)).to be false
      expect(subject.promote(pawn, pawn)).to be false
      expect(subject.promote(pawn, b_rook)).to be true
    end
  end
end