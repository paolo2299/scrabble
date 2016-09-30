class Tileset
  def initialize(score_mapping)
    @score_mapping = score_mapping
  end

  def tile(character)
    Tile.new(
      character: character.upcase,
      score: @score_mapping.fetch(character.upcase)
    )
  end

  def self.standard_tileset
    #TODO correct the standard scores
    mapping = {
      "A"=> 1,
      "B"=> 2,
      "C"=> 3,
      "D"=> 2,
      "E"=> 1,
      "F"=> 2,
      "G"=> 2,
      "H"=> 3,
      "I"=> 1,
      "J"=> 3,
      "K"=> 3,
      "L"=> 1,
      "M"=> 2,
      "N"=> 1,
      "O"=> 1,
      "P"=> 1,
      "Q"=> 10,
      "R"=> 1,
      "S"=> 1,
      "T"=> 1,
      "U"=> 1,
      "V"=> 5,
      "W"=> 2,
      "X"=> 10,
      "Y"=> 2,
      "Z"=> 10
    }
    new(mapping)
  end
end

class Tile
  attr_reader :character
  attr_reader :score

  def initialize(params)
    @character = params.fetch(:character)
    @score = params.fetch(:score)
  end

  class NoTile
  end
end
