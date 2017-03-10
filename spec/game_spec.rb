require 'spec_helper'
require 'board'
require 'tile'
require 'tile_bag'
require 'player'
require 'game'

describe Game do

  let(:game_id) { "123" }
  let(:player1_id) { "abc" }
  let(:player2_id) { "def" }
  let(:player1_score) { 0 }
  let(:player2_score) { 0 }
  let(:player1_index) { 0 }
  let(:player2_index) { 1 }

  let(:board) { Board.new_board }

  let(:tile_bag) { TileBag.new_tile_bag }

  let(:player_tiles) {
    [
      tile_bag.take_tile_with_letter!("C"),
      tile_bag.take_tile_with_letter!("A"),
      tile_bag.take_tile_with_letter!("T"),
      tile_bag.take_tile_with_letter!("C"),
      tile_bag.take_tile_with_letter!("H"),
      tile_bag.take_tile_with_letter!("J"),
      tile_bag.take_tile_with_letter!("K")
    ]
  }

  let(:c1) { player_tiles[0] }
  let(:a) { player_tiles[1] }
  let(:t) { player_tiles[2] }
  let(:c2) { player_tiles[3] }
  let(:h) { player_tiles[4] }
  let(:j) { player_tiles[5] }
  let(:k) { player_tiles[6] }

  let(:tile_rack) do
    rack = TileRack.new_tile_rack
    player_tiles.each do |tile|
      rack << tile
    end
    rack
  end

  let(:players) { [
    Player.new(player1_id, Player::PLAYER1, tile_rack, player1_score)
  ] }

  let(:player_to_act_index) { player1_index }
  let(:total_players) { 1 }

  let(:game_status) { Game::GameStatus::IN_PROGRESS }

  subject { Game.new(
    id: game_id,
    board: board,
    tile_bag: tile_bag,
    players: players,
    player_to_act_index: player_to_act_index,
    total_players: total_players,
    status: game_status
  )}

  describe "play!" do
    it "should raise an exception when a non-existent player attempts to play" do
      tile_ids = [
        c1.id,
        a.id,
        t.id
      ]
      positions = [
        [7, 5],
        [7, 6],
        [7, 7]
      ]
      expect { subject.play!("blah", tile_ids, positions) }.to raise_error do |error|
        expect(error).to be_a(GameError::PlayerNotFoundError)
      end
    end

    context "making the first move of the game" do
      it "should play the tiles if it is a real word crossing the center square" do
        tile_ids = [
          c1.id,
          a.id,
          t.id
        ]
        positions = [
          [7, 5],
          [7, 6],
          [7, 7]
        ]
        subject.play!(player1_id, tile_ids, positions)
        expect(subject.board.to_s).to eq(%Q{
---------------
---------------
---------------
---------------
---------------
-------C-------
-------A-------
-------T-------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
        }.strip)
      end

      it "should raise a relevant exception if it does not use the center square" do
        tile_ids = [
          c1.id,
          a.id,
          t.id
        ]
        positions = [
          [6, 5],
          [6, 6],
          [6, 7]
        ]
        expect { subject.play!(player1_id, tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMoveError::FirstMoveNotOnCenterError)
        end
        expect(subject.board).to be_empty
      end

      it "should raise a relevant exception if the tiles are not all in the same row or same column" do
        tile_ids = [
          c1.id,
          a.id,
          t.id
        ]
        positions = [
          [6, 5],
          [7, 6],
          [7, 7]
        ]
        expect { subject.play!(player1_id, tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMoveError::NotInSameRowOrSameColumnError)
        end
        expect(subject.board).to be_empty
      end

      it "should raise a relevant exception if there is a gap in the word" do
        tile_ids = [
          c1.id,
          a.id,
          t.id,
          c2.id,
          h.id
        ]
        positions = [
          [7, 5],
          [7, 6],
          [7, 7],
          [7, 9],
          [7, 10]
        ]
        expect { subject.play!(player1_id, tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMoveError::GapError)
        end
        expect(subject.board).to be_empty
      end

      it "should raise a relevant exception if it is not a real word" do
        tile_ids = [
          h.id,
          j.id,
          k.id
        ]
        positions = [
          [7, 5],
          [7, 6],
          [7, 7]
        ]
        expect { subject.play!(player1_id, tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMoveError::InvalidWordError)
        end
        expect(subject.board).to be_empty
      end
    end

    context "when the game has not started" do
      let(:game_status) { Game::GameStatus::WAITING_FOR_PLAYERS }

      it "should raise an exception" do
        tile_ids = [
          c1.id,
          a.id,
          t.id
        ]
        positions = [
          [7, 5],
          [7, 6],
          [7, 7]
        ]
        expect { subject.play!(player1_id, tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(GameError::GameNotInProgressError)
        end
      end
    end

    context "making a move on an already populated board" do

      let(:player_tiles) {
        [
          tile_bag.take_tile_with_letter!("P"),
          tile_bag.take_tile_with_letter!("R"),
          tile_bag.take_tile_with_letter!("R"),
          tile_bag.take_tile_with_letter!("O"),
          tile_bag.take_tile_with_letter!("T"),
          tile_bag.take_tile_with_letter!("D"),
          tile_bag.take_tile_with_letter!("G")
        ]
      }

      let(:p) { player_tiles[0] }
      let(:r1) { player_tiles[1] }
      let(:r2) { player_tiles[2] }
      let(:o) { player_tiles[3] }
      let(:t) { player_tiles[4] }
      let(:d) { player_tiles[5] }
      let(:g) { player_tiles[6] }

      let(:board) do
        Board.load_from_string!(%Q{
---------------
---------------
---------------
---------------
-------C-------
-------A-------
--PARROT-------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
        }, tile_bag)
      end

      it "should allow a legitimate word to be played" do
        tile_ids = [
          p.id,
          t.id
        ]
        positions = [
          [3, 5],
          [3, 7]
        ]
        subject.play!(player1_id, tile_ids, positions)
        expected = %Q{
---------------
---------------
---------------
---------------
-------C-------
---P---A-------
--PARROT-------
---T-----------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
        }.strip
        expect(subject.board.to_s).to eq(expected)
      end

      context "when the game is complete" do
        let(:game_status) { Game::GameStatus::COMPLETE }

        it "should raise an exception if a player tries to play" do
          tile_ids = [
            p.id,
            t.id
          ]
          positions = [
            [3, 5],
            [3, 7]
          ]
          expect { subject.play!(player1_id, tile_ids, positions) }.to raise_error do |error|
            expect(error).to be_a(GameError::GameNotInProgressError)
          end
        end
      end

      it "should raise a relevant exception if the tiles are not all in the same row or same column" do
        tile_ids = [
          p.id,
          r1.id,
          r2.id,
          o.id,
          t.id
        ]
        positions = [
          [3, 5],
          [3, 7],
          [3, 8],
          [3, 9],
          [4, 10]
        ]
        expect { subject.play!(player1_id, tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMoveError::NotInSameRowOrSameColumnError)
        end
      end

      it "should raise a relevant exception if there is a gap in the word" do
        tile_ids = [
          p.id,
          r1.id,
          r2.id,
          o.id,
          t.id
        ]
        positions = [
          [3, 5],
          [3, 7],
          [3, 8],
          [3, 9],
          [3, 11]
        ]
        expect { subject.play!(player1_id, tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMoveError::GapError)
        end
      end

      it "should raise a relevant exception if a non-real word is formed" do
        #forms DOG going down but DA going across
        allow(Dictionary).to receive(:valid_word?).with("DA").and_return(false)
        allow(Dictionary).to receive(:valid_word?).with("CAT").and_return(true)
        allow(Dictionary).to receive(:valid_word?).with("PARROT").and_return(true)
        allow(Dictionary).to receive(:valid_word?).with("DOG").and_return(true)
        tile_ids = [
          d.id,
          g.id,
        ]
        positions = [
          [6, 5],
          [6, 7]
        ]
        expect { subject.play!(player1_id, tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMoveError::InvalidWordError)
        end
      end

      it "should raise a relevant exception if non of the existing words are used to make a new word" do
        tile_ids = [
          d.id,
          o.id,
          g.id,
        ]
        positions = [
          [0, 1],
          [0, 2],
          [0, 3]
        ]
        expect { subject.play!(player1_id, tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMoveError::DidNotBuildOnExistingWordsError)
        end
      end
    end

    context "for a two player game" do
      let(:players) { [
        Player.new(player1_id, Player::PLAYER1, tile_rack, player1_score),
        Player.new(player2_id, Player::PLAYER2, tile_rack, player2_score)
      ] }
      let(:total_players) { 2 }

      context "when the current player is player1" do
        let(:player_to_act_index) { player1_index }

        it "should raise an exception when player2 tries to play" do
          tile_ids = [
            c1.id,
            a.id,
            t.id
          ]
          positions = [
            [7, 5],
            [7, 6],
            [7, 7]
          ]
          expect { subject.play!(player2_id, tile_ids, positions) }.to raise_error do |error|
            expect(error).to be_a(GameError::PlayerActedOutOfTurnError)
          end
        end

        it "should cause the player to act to be player2" do
          tile_ids = [
            c1.id,
            a.id,
            t.id
          ]
          positions = [
            [7, 5],
            [7, 6],
            [7, 7]
          ]
          subject.play!(player1_id, tile_ids, positions)
          expect(subject.player_to_act.position).to eq(:player2)
        end
      end

      context "the current player is player2" do
        let(:player_to_act_index) { player2_index }

        it "should raise an exception when player1 tries to play" do
          tile_ids = [
            c1.id,
            a.id,
            t.id
          ]
          positions = [
            [7, 5],
            [7, 6],
            [7, 7]
          ]
          expect { subject.play!(player1_id, tile_ids, positions) }.to raise_error do |error|
            expect(error).to be_a(GameError::PlayerActedOutOfTurnError)
          end
        end

        it "should cause the current player to be player1" do
          tile_ids = [
            c1.id,
            a.id,
            t.id
          ]
          positions = [
            [7, 5],
            [7, 6],
            [7, 7]
          ]
          subject.play!(player2_id, tile_ids, positions)
          expect(subject.player_to_act.position).to eq(:player1)
        end
      end
    end
  end

  describe "pass!" do
    it "should raise an exception when a non-existent player attempts to pass" do
      expect { subject.pass!("skdjfklsd") }.to raise_error do |error|
        expect(error).to be_a(GameError::PlayerNotFoundError)
      end
    end

    context "when the game has not started" do
      let(:game_status) { Game::GameStatus::WAITING_FOR_PLAYERS }

      it "should raise an exception" do
        expect { subject.pass!(player1_id) }.to raise_error do |error|
          expect(error).to be_a(GameError::GameNotInProgressError)
        end
      end
    end

    context "when the game is complete" do
      let(:game_status) { Game::GameStatus::COMPLETE }

      it "should raise an exception" do
        expect { subject.pass!(player1_id) }.to raise_error do |error|
          expect(error).to be_a(GameError::GameNotInProgressError)
        end
      end
    end

    context "for a two player game" do
      let(:players) { [
        Player.new(player1_id, Player::PLAYER1, tile_rack, player1_score),
        Player.new(player2_id, Player::PLAYER2, tile_rack, player2_score)
      ] }
      let(:total_players) { 2 }

      context "when the current player is player1" do
        let(:player_to_act_index) { player1_index }

        it "should cause the current player to be player2" do
          subject.pass!(player1_id)
          expect(subject.player_to_act.position).to eq(:player2)
        end

        it "should raise an exception when player2 attempts to pass" do
          expect { subject.pass!(player2_id) }.to raise_error do |error|
            expect(error).to be_a(GameError::PlayerActedOutOfTurnError)
          end
        end
      end

      context "when the current player is player2" do
        let(:player_to_act_index) { player2_index }

        it "should cause the current player to be player1" do
          subject.pass!(player2_id)
          expect(subject.player_to_act.position).to eq(:player1)
        end

        it "should raise an exception when player1 attempts to pass" do
          expect { subject.pass!(player1_id) }.to raise_error do |error|
            expect(error).to be_a(GameError::PlayerActedOutOfTurnError)
          end
        end
      end
    end
  end
end
