require_relative './tile_rack'

class Player
  attr_reader :id
  attr_reader :score
  attr_reader :position
  attr_reader :tile_rack
  attr_reader :name

  def self.new_player(player_name, position)
    tile_rack = TileRack.new_tile_rack
    new(random_id, position, player_name, tile_rack, 0)
  end

  def initialize(player_id, position, name, tile_rack, score)
    @id = player_id
    @position = position
    @tile_rack = tile_rack
    @score = score
    @name = name
  end

  def add_score!(score_to_add)
    @score += score_to_add
  end

  def copy
    tile_rack_copy = tile_rack.copy
    Player.new(id, position, name, tile_rack_copy, score)
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
      "id" => id,
      "tileRack" => tile_rack.to_hash,
      "position" => position,
      "score" => score,
      "name" => name
    }
  end

  def to_secretive_hash
    # only exposes information that it's OK for other players to see
    {
      "position" => position,
      "score" => score,
      "name" => name
    }
  end

  def self.from_hash(h)
    tile_rack = TileRack.from_hash(h.fetch("tileRack"))
    position = h.fetch("position")
    score = h.fetch("score")
    id = h.fetch("id")
    name = h.fetch("name")
    new(id, position, name, tile_rack, score)
  end

  private

  def self.random_id
    SecureRandom.uuid
  end
end
