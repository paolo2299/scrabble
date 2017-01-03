require 'spec_helper'
require 'board'
require 'tile'
require 'tile_bag'
require 'player'
require 'game'

describe Game do

  let(:game_id) { "123" }

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

  let(:player) { Player.new(Player::PLAYER1, tile_rack, 0) }

  subject { Game.new(game_id, board, tile_bag, player) }

  describe "play!" do
    context "when the current player is player1" do
      it "should cause the current player to be player2" do
        pending("introduction of 2 player games")
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
        subject.play!(tile_ids, positions)
        expect(subject.to_hash.fetch(:player)).to eq(:player2)
      end
    end

    context "when the current player is player2" do
      subject { Game.new(board, tile_bag, :player2) }

      it "should cause the current player to be player1" do
        pending("introduction of 2 player games")
        tiles = [
          PositionedTile.new(tile("c"), [7, 5]),
          PositionedTile.new(tile("a"), [7, 6]),
          PositionedTile.new(tile("t"), [7, 7]),
        ]
        subject.play!(tiles)
        expect(subject.to_hash.fetch(:player)).to eq(:player1)
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
        subject.play!(tile_ids, positions)
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
        expect { subject.play!(tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::FirstMoveNotOnCenterError)
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
        expect { subject.play!(tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::NotInSameRowOrSameColumnError)
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
        expect { subject.play!(tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::GapError)
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
        expect { subject.play!(tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::InvalidWordError)
        end
        expect(subject.board).to be_empty
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
        expect { subject.play!(tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::NotInSameRowOrSameColumnError)
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
        expect { subject.play!(tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::GapError)
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
        expect { subject.play!(tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::InvalidWordError)
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
        expect { subject.play!(tile_ids, positions) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::DidNotBuildOnExistingWordsError)
        end
      end
    end
  end

  describe "pass!" do
    context "when the current player is player1" do
      it "should cause the current player to be player2" do
        pending("introduction of 2 player games")
        subject.pass!
        expect(subject.to_hash.fetch(:player)).to eq(:player2)
      end
    end

    context "when the current player is player2" do
      subject { Game.new(board, tile_bag, :player2) }

      it "should cause the current player to be player1" do
        pending("introduction of 2 player games")
        subject.pass!
        expect(subject.to_hash.fetch(:player)).to eq(:player1)
      end
    end
  end
end
