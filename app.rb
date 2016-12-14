require 'sinatra'
require 'json'
require_relative './lib/game'

post "/games" do
  game = Game.new_game

  content_type "application/json"
  game.to_hash.to_json
end

get "/games/:game_id" do
  game = Game.from_id(params["game_id"])

  content_type "application/json"
  game.to_hash.to_json
end

post "/games/:game_id/play" do
  request.body.rewind
  request_payload = JSON.parse(request.body.read)

  game = Game.from_id(params["game_id"])
  tile_ids = request_payload.fetch("playedTiles").map {|data| data.fetch("id")}
  positions = request_payload.fetch("playedTiles").map {|data| data.fetch("position")}
  begin
    game.play!(tile_ids, positions)
  rescue InvalidMove => e
    status 400
    return {
      error_type: :invalid_move,
      error_data: e.data
    }.to_json
  end

  content_type "application/json"
  game.to_hash.to_json
end
