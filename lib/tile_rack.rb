class TileRack
  class OverFullError < StandardError; end
  class TileNotFoundError < StandardError; end

  CAPACITY = 7

  attr_reader :tiles

  def initialize(tiles)
    @tiles = tiles
  end

  def self.new_tile_rack
    new([])
  end

  def copy
    rack_copy = TileRack.new_tile_rack
    tiles.each do |tile|
      rack_copy << tile.dup
    end
    rack_copy
  end

  def capacity
    CAPACITY
  end

  def take_tile!(tile_id)
    tile = tiles.detect{|tile| tile.id == tile_id}
    unless tile
      message = "Tried to take tile #{tile_id} from tile rack with tile ids #{tiles.map(&:id).join(",")}"
      raise TileNotFoundError.new message
    end
    @tiles -= [tile]
    tile
  end

  def <<(tile)
    if tiles.count >= capacity
      raise OverFullError.new
    end
    tiles << tile
  end

  def count
    tiles.count
  end

  def to_hash
    rack = Array.new(CAPACITY)
    tiles.each_with_index do |tile, index|
      rack[index] = tile.to_hash
    end
    { "tiles" => rack }
  end

  def self.from_hash(h)
    tiles = h.fetch("tiles").map { |tile_hash| Tile.from_hash(tile_hash) }
    new(tiles)
  end
end
