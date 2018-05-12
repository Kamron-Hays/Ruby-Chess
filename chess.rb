#!/usr/bin/env ruby

require_relative "player"
require_relative "board"
require 'yaml'

class Chess

  def initialize
    @side = nil
    @white = nil
    @black = nil
    @board = nil
    @done = false
    @resign = false
    @skip_board_draw = false
  end

  def display_board
    if !@skip_board_draw
      @board.draw
    end
    @skip_board_draw = false
  end

  def display_help
    puts "\nEnter start and end coordinates to move a piece (for example c2c4)\n" +
         "or one of the following commands:\n" +
         "\n" +
         "save   (save the state of the current game)\n" +
         "load   (load a previously saved game)\n" +
         "resign (admit defeat)\n" +
         "help   (displays this message)\n" +
         "exit   (terminate the game, losing any unsaved states)\n"
  end

  def process_input
    input = (@side == :white) ? @white.get_input : @black.get_input

    if input == "load"
      puts "load game"
    elsif input == "save"
      puts "save game"
    elsif input == "exit" || input == "quit"
      @done = true
    elsif input == "resign"
      @resign = true
      puts (@side == :white) ? "Black wins!" : "White wins!"
    elsif input == "help" || input == "h"
      display_help
    elsif @board.valid_move?(input)
      success, message = @board.execute_move(input, @side)
      puts message if message
      if success
        @side = (@side == :white) ? :black : :white
      else
        @skip_board_draw = true        
      end
    else
      puts "Invalid move or command. Try again.\n"
      @skip_board_draw = true
    end
  end

  def get_yes_or_no(prompt)
    status = false
    print prompt
    response = gets.chomp.downcase
    response == 'y' || response == 'ye' || response == 'yes'
  end
  
  def play
    loop do
      @board = Board.new
      @board.setup
      @resign = false
      @side = :white

      answer = get_yes_or_no("Do you want White to be human? ")
      @white = answer ? Player.new(:white) : AI_Player.new(:white)

      answer = get_yes_or_no("Do you want Black to be human? ")
      @black = answer ? Player.new(:black) : AI_Player.new(:black)

      display_help

      loop do
        display_board

        if @board.check?(@side)
          if @board.mate?(@side)
            opponent = (@side == :white) ? "Black" : "White"
            puts "Checkmate! #{opponent} wins!"
            break
          else
            puts "Check!"
          end
        elsif @board.stalemate?(@player)
          puts "Stalemate!"
          break
        end

        process_input
        break if @done || @resign
      end

      break if @done
      play_again = get_yes_or_no("\nPlay again? ")
      break if !play_again
    end
  end
end

if __FILE__ == $0
  # this will only run if the script was the main, not load'd or require'd

  Chess.new.play
end
