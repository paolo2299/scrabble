require 'sinatra'
require 'json'
require_relative './lib/game'

post "/games" do
  game = Game.new_game
  game.to_hash.to_json
end

get "/games/:game_id" do
  game = Game.from_id(params["game_id"])
  game.to_hash.to_json
end

post "/games/:game_id/moves" do
  game = Game.from_id(params["game_id"])
  tile_ids = params["playedTiles"].map {|data| data.fetch("tileId")}
  positions = params["playedTiles"].map {|data| data.fetch("position")}
  game.play!(tile_ids, positions)
  game.to_hash.to_json
end
