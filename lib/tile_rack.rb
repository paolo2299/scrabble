class TileRack
  class OverFullError < StandardError; end

  CAPACITY = 7

  attr_reader :tiles

  def initialize
    @tiles = []
  end

  def capacity
    CAPACITY
  end

  def <<(tile)
    if tiles.count >= capacity
      raise OverFullError.new
    end
    tiles << tile
  end

  def to_hash
    rack = Array.new(CAPACITY)
    tiles.each_with_index do |tile, index|
      rack[index] = tile
    end
    rack
  end
end
