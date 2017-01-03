require 'json'

require_relative './tile_bag'

class Board
  class InvalidTilePlacementError < StandardError; end

  WIDTH = 15
  HEIGHT = 15
  CENTER = [7, 7].freeze
  TRIPLE_WORD_SCORES = [
    [0, 0],
    [0, 7],
    [0, 14],
    [7, 0],
    [7, 14],
    [14, 0],
    [14, 7],
    [14, 14]
  ].freeze
  DOUBLE_WORD_SCORES = [
    [1, 1],
    [2, 2],
    [3, 3],
    [4, 4],
    [13, 1],
    [12, 2],
    [11, 3],
    [10, 4],
    [1, 13],
    [2, 12],
    [3, 11],
    [4, 10],
    [13, 13],
    [12, 12],
    [11, 11],
    [10, 10]
  ].freeze
  TRIPLE_LETTER_SCORES = [
    [5, 1],
    [9, 1],
    [1, 5],
    [1, 9],
    [5, 13],
    [9, 13],
    [13, 5],
    [13, 9],
    [5, 5],
    [9, 5],
    [5, 9],
    [9, 9]
  ].freeze
  DOUBLE_LETTER_SCORES = [
    [0, 3],
    [0, 11],
    [14, 3],
    [14, 11],
    [3, 0],
    [11, 0],
    [3, 14],
    [11, 14],
    [6, 2],
    [7, 3],
    [8, 2],
    [2, 6],
    [3, 7],
    [2, 8],
    [6, 12],
    [7, 11],
    [8, 12],
    [12, 6],
    [11, 7],
    [12, 8],
    [6, 6],
    [6, 8],
    [8, 6],
    [8, 8]
  ].freeze

  def self.new_board
    tiles = Array.new(HEIGHT) { Array.new(WIDTH) }
    new(tiles)
  end

  def initialize(tiles)
    @tiles = tiles
    @placed_this_turn = []
  end

  def self.load_from_string!(string, tile_bag=nil)
    board = new_board
    tile_bag = tile_bag || TileBag.new_tile_bag
    string.strip.split("\n").each_with_index do |row_string, row_idx|
      row_string.each_char.with_index do |char, col_idx|
        if char != "-"
          board.place_tile!(tile_bag.take_tile_with_letter!(char), [col_idx, row_idx])
        end
      end
    end
    board.commit!
    board
  end

  def center
    CENTER
  end

  def commit!
    @placed_this_turn = []
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
    board_copy.commit!
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
    @placed_this_turn << position
  end

  def newly_played_tile?(position)
    @placed_this_turn.include?(position)
  end

  def triple_letter_score?(position)
    TRIPLE_LETTER_SCORES.include?(position)
  end

  def triple_word_score?(position)
    TRIPLE_WORD_SCORES.include?(position)
  end

  def double_letter_score?(position)
    DOUBLE_LETTER_SCORES.include?(position)
  end

  def double_word_score?(position)
    DOUBLE_WORD_SCORES.include?(position)
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
    {
      "playedTiles" => played_tiles,
      "multiplierTiles" => {
        "tripleWord" => self.class::TRIPLE_WORD_SCORES,
        "doubleWord" => self.class::DOUBLE_WORD_SCORES,
        "tripleLetter" => self.class::TRIPLE_LETTER_SCORES,
        "doubleLetter" => self.class::DOUBLE_LETTER_SCORES
      }
    }
  end

  def self.from_hash(h)
    tiles = Array.new(HEIGHT) { Array.new(WIDTH) }
    h.fetch("playedTiles").each do |played_tile_hash|
      col_idx, row_idx = played_tile_hash.fetch("position")
      tile = Tile.from_hash(played_tile_hash)
      tiles[row_idx][col_idx] = tile
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
      word_tiles = []
      word_positions = []
      row_or_col.each_with_index do |tile, index2|
        if tile.nil?
          #TODO this breaks if the first word played in the game is one letter
          if word_tiles.length > 1
            played_words << PlayedWord.new(word_tiles, word_positions, self)
          end
          word_tiles = []
          word_positions = []
        else
          word_tiles << tile
          word_positions << case orientation
            when :row then [index2, index1]
            else [index1, index2]
          end
          if index2 == row_or_col.size - 1
            played_words << PlayedWord.new(word_tiles, word_positions, self)
          end
        end
      end
    end
  end
end

class PlayedWord
  attr_reader :positions

  def initialize(tiles, positions, board)
    @board = board
    @tiles = tiles
    @positions = positions
  end

  def to_s
    @tiles.map(&:letter).join("").upcase
  end

  def score
    #@tiles.map(&:score).inject(&:+)
    word_score = 0
    multiplier = 1
    @tiles.each_with_index do |tile, index|
      if @board.newly_played_tile?(positions[index])
        #deal with letter multipliers
        if @board.triple_letter_score?(positions[index])
          word_score += tile.score * 3
        elsif @board.double_letter_score?(positions[index])
          word_score += tile.score * 2
        else
          word_score += tile.score
        end
        #deal with word multipliers
        if @board.triple_word_score?(positions[index])
          multiplier *= 3
        elsif @board.double_word_score?(positions[index])
          multiplier *= 2
        end
      else
        word_score += tile.score
      end
    end
    word_score * multiplier
  end

  def ==(another_played_word)
    self.to_s == another_played_word.to_s &&
      self.positions == another_played_word.positions
  end
end
