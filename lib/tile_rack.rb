class TileRack
  class OverFullError < StandardError; end
  class TileNotFoundError < StandardError; end

  CAPACITY = 7

  attr_reader :tiles

  def initialize
    @tiles = []
  end

  def copy
    rack_copy = TileRack.new
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

  def to_a
    rack = Array.new(CAPACITY)
    tiles.each_with_index do |tile, index|
      rack[index] = tile.to_hash
    end
    rack
  end
end
