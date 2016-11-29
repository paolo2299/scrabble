require 'json'

class Board
  class InvalidTilePlacementError < StandardError; end

  WIDTH = 15
  HEIGHT = 15
  CENTER = [7, 7].freeze

  def self.new_board
    tiles = Array.new(HEIGHT) { Array.new(WIDTH) }
    new(tiles)
  end

  def initialize(tiles)
    @tiles = tiles
  end

  def self.load_from_string!(string, tile_bag=nil)
    board = new
    tile_bag = tile_bag || TileBag.new_tile_bag
    string.strip.split("\n").each_with_index do |row_string, row_idx|
      row_string.each_char.with_index do |char, col_idx|
        if char != "-"
          board.place_tile!(tile_bag.take_tile_with_letter!(char), [col_idx, row_idx])
        end
      end
    end
    board
  end

  def center
    CENTER
  end

  def has_adjacent_tiles?(position)
    x, y = position
    if (x < WIDTH - 1) && !tile([x + 1, y]).nil?
      return true
    elsif (x > 0) && !tile([x - 1, y]).nil?
      return true
    elsif (y < HEIGHT - 1) && !tile([x, y + 1]).nil?
      return true
    elsif (y > 0) && !tile([x, y - 1]).nil?
      return true
    end
    return false
  end

  def empty?
    @tiles.flatten.compact.empty?
  end

  def tile(position)
    @tiles[position[1]][position[0]]
  end

  def copy
    board_copy = Board.new_board
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

  def to_hash
    played_tiles = []
    @tiles.each_with_index do |tile_row, row_idx|
      tile_row.each_with_index do |tile, col_idx|
        next unless tile
        played_tiles << tile.to_hash.merge({
          position: [col_idx, row_idx]
        })
      end
    end
    { "playedTiles" => played_tiles }
  end

  def self.from_hash(h)
    tiles = Array.new(HEIGHT) { Array.new(WIDTH) }
    h.fetch("playedTiles").each do |played_tile_hash|
      col_idx, row_idx = played_tile_hash.fetch("position")
      tile = Tile.from_hash(played_tile_hash)
      tiles[row_idx, col_idx] = tile
    end
    new(tiles)
  end

  def to_s
    s = ""
    @tiles.each do |tile_row|
      tile_row.each do |tile|
        if tile.nil?
          s += "-"
        else
          s += tile.letter.upcase
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
          word += tile.letter
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
