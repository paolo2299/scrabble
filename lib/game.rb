require 'errors'

class Game
  WORDS = %w{
    CAT
    DOG
    PARROT
  }

  attr_reader :board

  def initialize(board)
    @board = board
  end

  def play_tiles!(positioned_tiles)
    validate_move!(positioned_tiles)
    positioned_tiles.each do |positioned_tile|
      board.place_tile!(
        positioned_tile.tile,
        positioned_tile.position
      )
    end
  end

  private

  def valid_word?(word)
    WORDS.include?(word)
  end

  def validate_move!(positioned_tiles)
    first_move = board.empty?
    if first_move
      unless positioned_tiles.map(&:position).include?(board.center)
        raise InvalidMove::FirstMoveNotOnCenterError.new
      end
    end

    #all tiles must be in same row or same column
    cols = positioned_tiles.map(&:position).map{|p| p[0]}.uniq
    rows = positioned_tiles.map(&:position).map{|p| p[1]}.uniq
    unless (cols.size == 1) || (rows.size == 1)
      raise InvalidMove::NotInSameRowOrSameColumnError.new
    end

    #any gap in the played tiles must be filled by other tiles on the board
    #first check if this is being played on a row or column
    to_check = (cols.size == 1) ? :rows : :cols
    check_for_gaps = (to_check == :rows) ? rows : cols
    lowest = check_for_gaps.min
    highest = check_for_gaps.max
    gaps = (lowest..highest).to_a - check_for_gaps
    gaps.each do |gap|
      position = case to_check
                 when :rows then [cols[0], gap]
                 when :cols then [gap, rows[0]]
                 end
      if board.tile(position).nil?
        raise InvalidMove::GapError.new
      end
    end

    #validate all new words are real words
    board_copy = board.copy
    positioned_tiles.each do |positioned_tile|
      board_copy.place_tile!(
        positioned_tile.tile, 
        positioned_tile.position
      )
    end
    new_played_words = board_copy.all_played_words - board.all_played_words
    new_played_words.each do |played_word|
      unless valid_word?(played_word.word)
        raise InvalidMove::NotAWordError.new played_word.word
      end
    end

    #validate that at least one new word uses a tile that was already on the board
    
  end
end

class PositionedTile
  attr_reader :tile
  attr_reader :position

  def initialize(tile, position)
    @tile = tile
    @position = position
  end

  def ==(other_positioned_tile)
    self.tile.character == other_positioned_tile.character &&
      self.position == other_positioned_tile.position
  end
end

