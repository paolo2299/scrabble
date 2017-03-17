require 'securerandom'
require_relative './errors'
require_relative './tile_bag'
require_relative './board'
require_relative './player'
require_relative './dictionary'

class Game
  #TODO use a database instead of file storage
  SAVE_FOLDER = "./data/saves"
  PLAYER_1_INDEX = 0

  class GameStatus
    WAITING_FOR_PLAYERS = :waiting_for_players
    IN_PROGRESS = :in_progress
    COMPLETE = :complete
  end

  attr_reader :players
  attr_reader :tile_bag
  attr_reader :board
  attr_reader :id
  attr_reader :total_players
  attr_reader :status

  def self.new_game(num_players = 1)
    game_status = if num_players > 1
      GameStatus::WAITING_FOR_PLAYERS
    else
      GameStatus::IN_PROGRESS
    end

    return Game.new(
      id: random_id,
      board: Board.new_board,
      tile_bag: TileBag.new_tile_bag,
      players: [Player.new_player1],
      player_to_act_index: PLAYER_1_INDEX,
      status: game_status,
      total_players: num_players
    )
  end

  def self.from_id(game_id)
    return load_from_file(game_id)
  end

  def save!
    filename = File.join(SAVE_FOLDER, id)
    File.open(filename, "w") do |save_file|
      save_file.write(to_hash.to_json)
    end
  end

  def self.load_from_file(game_id)
    filename = File.join(SAVE_FOLDER, game_id)
    if File.exist?(filename)
      game_hash = JSON.parse(File.read(filename))
      return Game.from_hash(game_hash)
    end
    raise GameError::GameNotFoundError.new game_id
  end

  def initialize(properties)
    @id = properties.fetch(:id)
    @board = properties.fetch(:board)
    @tile_bag = properties.fetch(:tile_bag)
    @players = properties.fetch(:players)
    @player_to_act_index = properties.fetch(:player_to_act_index)
    @total_players = properties.fetch(:total_players)
    @status = properties.fetch(:status)
    refill_tile_racks!
    save!
  end

  def player_to_act
    players[@player_to_act_index]
  end

  def player2_id
    players[1].id
  end

  def player1_id
    players.first.id
  end

  def start_game!
    @status = GameStatus::IN_PROGRESS
  end

  def add_second_player!
    unless players.count == 1
      raise GameError::TooManyPlayersError.new
    end
    players << Player.new_player2
    if players.count == total_players
      start_game!
    end
  end

  def player_from_id(player_id)
    unless player = players.find {|player| player.id == player_id}
      message = "player_id #{player_id} not valid for game #{id}"
      raise GameError::PlayerNotFoundError.new(message)
    end
    player
  end

  def play!(player_id, tile_ids, positions)
    validate_player_to_act!(player_id)
    score = validate_move!(tile_ids, positions)
    play_tiles!(tile_ids, positions)
    player_to_act.add_score!(score)
    refill_tile_racks!
    board.commit!
    next_players_turn!
    save!
  end

  def validate_player_to_act!(player_id)
    unless in_progress?
      raise GameError::GameNotInProgressError.new
    end
    player = player_from_id(player_id)
    unless player.id == player_to_act.id
      message = "player #{player_id} attempted to act out of turn"
      raise GameError::PlayerActedOutOfTurnError.new(message)
    end
  end

  def in_progress?
    status.to_sym == Game::GameStatus::IN_PROGRESS
  end

  def pass!(player_id)
    validate_player_to_act!(player_id)
    next_players_turn!
    save!
  end

  def to_hash
    {
      "id" => id,
      "players" => players.map(&:to_hash),
      "board" => board.to_hash,
      "tileBag" => tile_bag.to_hash,
      "playerToActIndex" => @player_to_act_index,
      "totalPlayers" => total_players,
      "status" => status
    }
  end

  def to_hash_from_players_perspective(player_id)
    player = player_from_id(player_id)
    player_details =
    {
      "id" => id,
      "player" => player.to_hash,
      "board" => board.to_hash,
      "playerToAct" => player_to_act.position,
      "totalPlayers" => total_players,
      "status" => status,
      "players" => players.map do |player|
        {
          "position" => player.position,
          "score" => player.score
        }
      end
    }
  end

  def self.from_hash(h)
    players = h.fetch("players").map do |player_hash|
      Player.from_hash(player_hash)
    end
    return new(
      id: h.fetch("id"),
      board: Board.from_hash(h.fetch("board")),
      tile_bag: TileBag.from_hash(h.fetch("tileBag")),
      players: players,
      player_to_act_index: h.fetch("playerToActIndex"),
      status: h.fetch("status"),
      total_players: h.fetch("totalPlayers")
    )
  end

  private

  def self.random_id
    SecureRandom.uuid
  end

  def next_players_turn!
    @player_to_act_index = (@player_to_act_index + 1) % players.count
  end

  def play_tiles!(tile_ids, positions)
    tile_ids.zip(positions).each do |tile_id, position|
      tile = player_to_act.take_tile!(tile_id)
      board.place_tile!(
        tile,
        position
      )
    end
  end

  def valid_word?(word)
    Dictionary.valid_word?(word)
  end

  def validate_move!(tile_ids, positions)
    first_move = board.empty?
    if first_move
      unless positions.include?(board.center)
        raise InvalidMoveError::FirstMoveNotOnCenterError.new
      end
    end

    #all tiles must be in same row or same column
    cols = positions.map{|p| p[0]}.uniq
    rows = positions.map{|p| p[1]}.uniq
    unless (cols.size == 1) || (rows.size == 1)
      raise InvalidMoveError::NotInSameRowOrSameColumnError.new
    end

    #any gap in the played tiles must be filled by other tiles on the board
    #first check if this is being played on a row or column
    to_check = (cols.size == 1) ? :rows : :cols
    check_for_gaps = (to_check == :rows) ? rows : cols
    lowest = check_for_gaps.min
    highest = check_for_gaps.max
    gaps = (lowest..highest).to_a - check_for_gaps
    gaps.each do |gap|
      position = case to_check
                 when :rows then [cols[0], gap]
                 when :cols then [gap, rows[0]]
                 end
      if board.tile(position).nil?
        raise InvalidMoveError::GapError.new
      end
    end

    #validate all new words are real words and that the player has the
    #specified tiles
    board_copy = board.copy
    player_copy = player_to_act.copy
    tile_ids.zip(positions).each do |tile_id, position|
      tile = player_copy.take_tile!(tile_id)
      board_copy.place_tile!(
        tile,
        position
      )
    end
    new_played_words = board_copy.all_played_words - board.all_played_words
    invalid_words = new_played_words.reject{|w| valid_word?(w.to_s)}
    if invalid_words.any?
      data = {type: :invalid_word, invalid_words: invalid_words.map(&:to_s)}
      raise InvalidMoveError::InvalidWordError.new("invalid words", data)
    end

    unless first_move
      built_on_existing_words = positions.any? do |position|
        board.has_adjacent_tiles?(position)
      end
      unless built_on_existing_words
        raise InvalidMoveError::DidNotBuildOnExistingWordsError.new
      end
    end

    score = new_played_words.map(&:score).inject(&:+)
    return score
  end

  def refill_tile_racks!
    players.each { |player| player.fill_tile_rack!(tile_bag) }
  end
end

class PositionedTile
  attr_reader :tile_id
  attr_reader :position

  def initialize(tile_id, position)
    @tile_id = tile_id
    @position = position
  end
end
