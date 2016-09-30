class Board
  class InvalidTilePlacementError < StandardError; end

  attr_reader :width
  attr_reader :height

  def initialize(params)
    @width = params.fetch(:width)
    @height = params.fetch(:height)
    @tiles = Array.new(@height) { Array.new(@width) }
  end

  def load_from_string!(string, tileset)
    string.strip.split("\n").each_with_index do |row_string, row_idx|
      row_string.each_char.with_index do |char, col_idx|
        if char != "-"
          @tiles[row_idx][col_idx] = tileset.tile(char)
        end
      end
    end
  end

  def place_tile!(tile, position)
    unless (0..(width - 1)).include?(position[0])
      raise InvalidTilePlacementError, "column index #{position[0]} is not between #{0} and #{width - 1}" 
    end
    unless (0..(height - 1)).include?(position[1])
      raise InvalidTilePlacementError, "row index #{position[1]} is not between #{0} and #{height - 1}" 
    end
    unless @tiles[position[1]][position[0]].nil?
      raise InvalidTilePlacementError, "there is already a tile at position [#{position[0]}, #{position[1]}]" 
    end
    @tiles[position[1]][position[0]] = tile
  end

  def all_played_words
    played_words = []
    rows = (0..(height - 1)).map do |row_num| 
      @tiles[row_num]
    end
    cols = (0..(width - 1)).map do |col_num|
      (0..(height - 1)).map do |row_num|
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
          s += tile.character
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
