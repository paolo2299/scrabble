require 'sinatra'
require 'json'
require_relative './initializers/pusher.rb'
require_relative './lib/game'

post "/games" do
  game = Game.new_game

  content_type "application/json"
  game.to_hash_from_players_perspective(game.player1_id).to_json
end

post "/games/:game_id/players" do
  game = Game.from_id(params["gameId"])
  begin
    game.add_second_player!
  rescue ScrabbleError => e
    return handle_scrabble_error(e)
  end
  player_id = game.player2_id

  content_type "application/json"
  game.to_hash_from_players_perspective(player_id).to_json
end

get "/pusher_test" do
  begin
    Pusher.trigger('scrabbleChannel', 'testEvent', :thisIs => 'someData')
  rescue Pusher::Error => e
    puts "pusher error: #{e.class}: #{e}"
  end
  "OK"
end

get "/games/:game_id" do
  game = Game.from_id(params["gameId"])
  player_id = params["playerId"]

  content_type "application/json"
  game.to_hash_from_players_perspective(player_id).to_json
end

post "/games/:game_id/play" do
  request.body.rewind
  request_payload = JSON.parse(request.body.read)

  game = Game.from_id(params["game_id"])
  player_id = request_payload.fetch("playerId")
  tile_ids = request_payload.fetch("playedTiles").map {|data| data.fetch("id")}
  positions = request_payload.fetch("playedTiles").map {|data| data.fetch("position")}
  begin
    game.play!(player_id, tile_ids, positions)
  rescue ScrabbleError => e
    return handle_scrabble_error(e)
  end

  content_type "application/json"
  game.to_hash_from_players_perspective(player_id).to_json
end

def handle_scrabble_error(e)
  status 400
  return {
    errorType: e.error_type,
    errorSubType: e.error_sub_type,
    errorData: e.data
  }.to_json
end
