class Tile
  attr_reader :character

  def initialize(character)
    @character = character
  end

  def score
    #TODO correct the standard scores
    {
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
    }.fetch(character.upcase)
  end
end
