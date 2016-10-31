require_relative './tile'

class TileBag
  TILE_FREQUENCIES = [
    ["A", 9],
    ["B", 2],
    ["C", 2],
    ["D", 4],
    ["E", 12],
    ["F", 2],
    ["G", 3],
    ["H", 2],
    ["I", 9],
    ["J", 1],
    ["K", 1],
    ["L", 4],
    ["M", 2],
    ["N", 6],
    ["O", 8],
    ["P", 2],
    ["Q", 1],
    ["R", 6],
    ["S", 4],
    ["T", 6],
    ["U", 4],
    ["V", 2],
    ["W", 2],
    ["X", 1],
    ["Y", 2],
    ["Z", 1]
  ]

  def initialize
    @tiles = []
    generate_all_tiles!
  end

  def count
    tiles.count
  end

  def empty?
    count == 0
  end

  def include?(tile)
    tiles.include?(tile)
  end

  def random_draw!(number)
    drawn = tiles.shuffle.take(number)
    @tiles -= drawn
    drawn
  end

  def take_tile_with_letter!(letter)
    tile = tiles.find {|tile| tile.letter == letter.upcase}
    if tile
      @tiles -= [tile]
    end
    tile
  end

  private

  attr_reader :tiles

  def generate_all_tiles!
    current_index = 0
    TILE_FREQUENCIES.each do |letter, frequency|
      (current_index...(current_index + frequency)).each do |tile_id|
        tiles << Tile.new(tile_id, letter)
      end
      current_index += frequency
    end
  end
end
