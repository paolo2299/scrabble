require 'errors'

class Game
  WORDS = %w{
    cat
    dog
    parrot
  }

  attr_reader :board

  def initialize(board, tileset)
    @board = board
    @tileset = tileset
  end

  def play_tiles!(tiles)
    validate_move!(tiles)
  end

  private

  def valid_word?(word)
    WORDS.include?(word)
  end

  def validate_move!(tiles)
    #validate all new words are real words
    board_copy = board.copy
    tiles.each do |tile|
      board_copy.place_tile!(tile)
    end
    new_played_words = board_copy.all_played_words - board.all_played_words
    new_played_words.each do |played_word|
      unless valid_word?(played_words.word)
        raise InvalidMove::NotAWordError.new
      end
    end
  end
end

class PositionedTile
  attr_reader :tile
  attr_reader :position

  def initialize(tile, position)
    @tile = tile
    @position = position
  end
end

