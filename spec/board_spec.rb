require_relative "spec_helper"
require_relative "../board"

describe Board do

  # The 'subject' variable will automatically be initialized with a new Board
  # object prior to each test case.

  describe "#execute_move(move, side)" do

    it "Can't move a non-existent piece" do
      status, message = subject.execute_move("b1b2", :white)
      expect(status).to be false
      expect(message).to eql "There is no piece at b1. Try again."
    end

    it "Can't move opponent's piece" do
      piece = Pawn.new("b1", :black, subject)
      status, message = subject.execute_move("b1b2", :white)
      expect(status).to be false
      expect(message).to eql "The Pawn at b1 is not yours. Try again."
    end

    it "Can't move to friendly occupied square" do
      piece1 = Pawn.new("b1", :white, subject)
      piece2 = Knight.new("b2", :white, subject)
      status, message = subject.execute_move("b1b2", :white)
      expect(status).to be false
      expect(message).to eql "The Pawn at b1 cannot legally move to b2. Try again."
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
        expect(message).to eql "The Pawn at b3 cannot legally move to b5. Try again."
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
        expect(message).to eql "The Pawn at b2 cannot legally move to b1. Try again."
        status, message = subject.execute_move("b2a1", :white)
        expect(status).to be false
        expect(message).to eql "The Pawn at b2 cannot legally move to a1. Try again."
        status, message = subject.execute_move("b2a2", :white)
        expect(status).to be false
        expect(message).to eql "The Pawn at b2 cannot legally move to a2. Try again."
        status, message = subject.execute_move("b2c1", :white)
        expect(status).to be false
        expect(message).to eql "The Pawn at b2 cannot legally move to c1. Try again."
        status, message = subject.execute_move("b2c2", :white)
        expect(status).to be false
        expect(message).to eql "The Pawn at b2 cannot legally move to c2. Try again."
        status, message = subject.execute_move("b2c3", :white)
        expect(status).to be false
        expect(message).to eql "The Pawn at b2 cannot legally move to c3. Try again."
        status, message = subject.execute_move("b2a3", :white)
        expect(status).to be false
        expect(message).to eql "The Pawn at b2 cannot legally move to a3. Try again."
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

      # Test en passant capture here
    end

    #########################
    # Test knight movements #
    #########################

    context "Given a knight" do
      # make sure knight moves properly
    end

    #######################
    # Test rook movements #
    #######################

    context "Given a rook" do
      it "Can move forward, backward, and laterally" do
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

      it "Must stop sliding when it runs into another piece" do
        piece = Rook.new("a3", :black, subject)
        pawn = Pawn.new("h3", :black, subject)
        status, message = subject.execute_move("a3g3", :black)
        expect(status).to be true
        status, message = subject.execute_move("g3h3", :black)
        expect(status).to be false
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

    #######################
    # Test King movements #
    #######################

    context "Given a king" do
      it "Can't move into check" do
        King.new("e1", :white, subject)
        Queen.new("f3", :black, subject)
        status, message = subject.execute_move("e1e2", :white)
        expect(status).to be false
        expect(message).to eql "You cannot move your King into check. Try again."
      end
    end
  end

end