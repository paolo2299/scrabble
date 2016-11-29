require_relative './tile_rack'

class Player
  PLAYER1 = :player1
  PLAYER2 = :player2

  attr_reader :position
  attr_reader :tile_rack

  def self.new_player1
    tile_rack = TileRack.new_tile_rack
    new(PLAYER1, tile_rack)
  end

  def initialize(position, tile_rack)
    @position = position
    @tile_rack = tile_rack
  end

  def copy
    tile_rack_copy = tile_rack.copy
    Player.new(position, tile_rack_copy)
  end

  def take_tile!(tile_id)
    tile_rack.take_tile!(tile_id)
  end

  def fill_tile_rack!(tile_bag)
    num_tiles_needed = tile_rack.capacity - tile_rack.count
    tiles = tile_bag.random_draw!(num_tiles_needed)
    tiles.each do |tile|
      tile_rack << tile
    end
  end

  def to_hash
    {
      "tileRack" => tile_rack.to_hash,
      "position" => position
    }
  end

  def self.from_hash(h)
    tile_rack = TileRack.from_hash(h.fetch("tileRack"))
    position = h.fetch("position").to_sym
    new(position, tile_rack)
  end
end
