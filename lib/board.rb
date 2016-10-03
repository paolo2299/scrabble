require 'json'

class Board
  class InvalidTilePlacementError < StandardError; end

  WIDTH = 15
  HEIGHT = 15
  CENTER = [7, 7].freeze

  def initialize
    @tiles = Array.new(HEIGHT) { Array.new(WIDTH) }
  end

  def self.load_from_string!(string)
    board = new
    string.strip.split("\n").each_with_index do |row_string, row_idx|
      row_string.each_char.with_index do |char, col_idx|
        if char != "-"
          board.place_tile!(Tile.new(char), [col_idx, row_idx])
        end
      end
    end
    board
  end

  def center
    CENTER
  end

  def empty?
    @tiles.flatten.compact.empty?
  end

  def tile(position)
    @tiles[position[1]][position[0]]
  end

  def copy
    board_copy = Board.new
    @tiles.each_with_index do |tile_row, row_idx|
      tile_row.each_with_index do |tile, col_idx|
        unless tile.nil?
          board_copy.place_tile!(tile.dup, [col_idx, row_idx])
        end
      end
    end
    board_copy
  end

  def place_tile!(tile, position)
    unless (0..(WIDTH - 1)).include?(position[0])
      raise InvalidTilePlacementError, "column index #{position[0]} is not between #{0} and #{WIDTH - 1}" 
    end
    unless (0..(HEIGHT - 1)).include?(position[1])
      raise InvalidTilePlacementError, "row index #{position[1]} is not between #{0} and #{HEIGHT - 1}" 
    end
    unless @tiles[position[1]][position[0]].nil?
      raise InvalidTilePlacementError, "there is already a tile at position [#{position[0]}, #{position[1]}]" 
    end
    @tiles[position[1]][position[0]] = tile
  end

  def all_played_words
    played_words = []
    rows = (0..(HEIGHT - 1)).map do |row_num| 
      @tiles[row_num]
    end
    cols = (0..(WIDTH - 1)).map do |col_num|
      (0..(HEIGHT - 1)).map do |row_num|
        @tiles[row_num][col_num]
      end
    end
    add_played_words(played_words, rows, :row)
    add_played_words(played_words, cols, :col)
    played_words
  end

  def to_s
    s = ""
    @tiles.each do |tile_row|
      tile_row.each do |tile|
        if tile.nil?
          s += "-"
        else
          s += tile.character.upcase
        end
      end
      s += "\n"
    end
    s.strip
  end

  private

  def add_played_words(played_words, rows_or_cols, orientation)
    rows_or_cols.each_with_index do |row_or_col, index1|
      word = ""
      start_position = nil
      row_or_col.each_with_index do |tile, index2|
        if tile.nil?
          if word.length > 1
            add_played_word(played_words, word, start_position, index1, orientation)
          end
          word = ""
          start_position = nil
        else
          word += tile.character
          if !start_position
            start_position = index2
          end
          if index2 == row_or_col.size - 1
            add_played_word(played_words, word, start_position, index1, orientation)
          end
        end
      end
    end
  end

  def add_played_word(played_words, word, start_position, index, orientation)
    case orientation
    when :row
      played_words << PlayedWord.new(word.upcase, [start_position, index], :across)
    else
      played_words << PlayedWord.new(word.upcase, [index, start_position], :down)
    end
  end
end

class PlayedWord
  attr_reader :word
  attr_reader :position
  attr_reader :direction

  def initialize(word, position, direction)
    @word = word
    @position = position
    @direction = direction
  end

  def ==(another_played_word)
    self.word == another_played_word.word &&
      self.position == another_played_word.position &&
      self.direction == another_played_word.direction
  end
end
