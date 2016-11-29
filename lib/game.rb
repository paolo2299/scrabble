require 'securerandom'
require_relative './errors'
require_relative './tile_bag'
require_relative './board'
require_relative './player'
require_relative './dictionary'

class Game
  class GameNotFoundError < StandardError; end;

  #TODO use a database instead of file storage
  SAVE_FOLDER = "./data/saves"

  attr_reader :player
  attr_reader :tile_bag
  attr_reader :board
  attr_reader :id

  def self.new_game
    board = Board.new_board
    tile_bag = TileBag.new_tile_bag
    player1 = Player.new_player1
    game_id = random_id
    game = Game.new(game_id, board, tile_bag, player1)
    GAMES_CACHE[game_id] = game
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
    raise GameNotFoundError.new game_id
  end

  def initialize(game_id, board, tile_bag, player)
    @id = game_id
    @board = board
    @tile_bag = tile_bag
    @player = player
    refill_player_tile_rack!
    save!
  end

  def play!(tile_ids, positions)
    validate_move!(tile_ids, positions)
    play_tiles!(tile_ids, positions)
    refill_player_tile_rack!
    next_players_turn!
    save!
  end

  def pass!
    next_players_turn!
    save!
  end

  def to_hash
    {
      "id" => id,
      "player" => player.to_hash,
      "board" => board.to_hash,
      "tileBag" => tile_bag.to_hash
    }
  end

  def self.from_hash(h)
    game_id = h.fetch("id")
    player = Player.from_hash(h.fetch("player"))
    board = Board.from_hash(h.fetch("board"))
    tile_bag = TileBag.from_hash(h.fetch("tileBag"))
    new(game_id, board, tile_bag, player)
  end

  private

  def self.random_id
    SecureRandom.uuid
  end

  def next_players_turn!
    #if @current_player == :player1
    #  @current_player = :player2
    #else
    #  @current_player = :player1
    #end
  end

  def play_tiles!(tile_ids, positions)
    tile_ids.zip(positions).each do |tile_id, position|
      tile = player.take_tile!(tile_id)
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
        raise InvalidMove::FirstMoveNotOnCenterError.new
      end
    end

    #all tiles must be in same row or same column
    cols = positions.map{|p| p[0]}.uniq
    rows = positions.map{|p| p[1]}.uniq
    unless (cols.size == 1) || (rows.size == 1)
      raise InvalidMove::NotInSameRowOrSameColumnError.new
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
        raise InvalidMove::GapError.new
      end
    end

    #validate all new words are real words and that the player has the
    #specified tiles
    board_copy = board.copy
    player_copy = player.copy
    tile_ids.zip(positions).each do |tile_id, position|
      tile = player_copy.take_tile!(tile_id)
      board_copy.place_tile!(
        tile,
        position
      )
    end
    new_played_words = board_copy.all_played_words - board.all_played_words
    new_played_words.each do |played_word|
      unless valid_word?(played_word.word)
        raise InvalidMove::NotAWordError.new played_word.word
      end
    end

    unless first_move
      built_on_existing_words = positions.any? do |position|
        board.has_adjacent_tiles?(position)
      end
      unless built_on_existing_words
        raise InvalidMove::DidNotBuildOnExistingWordsError.new
      end
    end
  end

  def refill_player_tile_rack!
    player.fill_tile_rack!(tile_bag)
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
