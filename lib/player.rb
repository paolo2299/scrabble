require 'tile_rack'

class Player
  PLAYER1 = :player1
  PLAYER2 = :player2

  attr_reader :position
  attr_reader :tile_rack

  def self.new_player1
    tile_rack = TileRack.new
    new(PLAYER1, tile_rack)
  end

  def initialize(position, tile_rack)
    @position = position
    @tile_rack = tile_rack
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
      position: position,
      tile_rack: tile_rack.to_hash
    }
  end
end
