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

  def hash
    equality_data.hash
  end

  def ==(another_played_word)
    equality_data == another_played_word.equality_data
  end

  def eql?(another_played_word)
    self == another_played_word
  end

  def equality_data
    [@tiles.map(&:id), positions]
  end
end
