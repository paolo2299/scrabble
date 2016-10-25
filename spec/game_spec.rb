require 'spec_helper'
require 'board'
require 'tile'
require 'game'

describe Game do

  def tile(letter)
    tile_bag.find_tile!(letter)
  end

  let(:board) { Board.new }
  let(:player) { :player1 }
  let(:tile_bag) { TileBag.new }
  let(:tile_id) { 0 }
  subject { Game.new(board) }

  describe "play!" do
    context "when the current player is player1" do
      it "should cause the current player to be player2" do
        tiles = [
          PositionedTile.new(tile("c"), [7, 5]),
          PositionedTile.new(tile("a"), [7, 6]),
          PositionedTile.new(tile("t"), [7, 7]),
        ]
        subject.play!(player, tiles)
        expect(subject.to_hash.fetch(:player)).to eq(:player2)
      end
    end

    context "when the current player is player2" do
      subject { Game.new(board, :player2) }

      it "should cause the current player to be player1" do
        tiles = [
          PositionedTile.new(tile("c"), [7, 5]),
          PositionedTile.new(tile("a"), [7, 6]),
          PositionedTile.new(tile("t"), [7, 7]),
        ]
        subject.play!(player, tiles)
        expect(subject.to_hash.fetch(:player)).to eq(:player1)
      end
    end

    context "making the first move of the game" do
      it "should play the tiles if it is a real word crossing the center square" do
        tiles = [
          PositionedTile.new(tile("c"), [7, 5]),
          PositionedTile.new(tile("a"), [7, 6]),
          PositionedTile.new(tile("t"), [7, 7]),
        ]
        subject.play!(player, tiles)
        expect(subject.to_hash.fetch(:board)).to eq(%Q{
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
        tiles = [
          PositionedTile.new(tile("c"), [6, 5]),
          PositionedTile.new(tile("a"), [6, 6]),
          PositionedTile.new(tile("t"), [6, 7]),
        ]
        expect { subject.play!(player, tiles) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::FirstMoveNotOnCenterError)
        end
        expect(board).to be_empty
      end

      it "should raise a relevant exception if the tiles are not all in the same row or same column" do
        tiles = [
          PositionedTile.new(tile("c"), [6, 5]),
          PositionedTile.new(tile("a"), [7, 6]),
          PositionedTile.new(tile("t"), [7, 7]),
        ]
        expect { subject.play!(player, tiles) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::NotInSameRowOrSameColumnError)
        end
        expect(board).to be_empty
      end

      it "should raise a relevant exception if there is a gap in the word" do
        tiles = [
          PositionedTile.new(tile("c"), [7, 5]),
          PositionedTile.new(tile("a"), [7, 6]),
          PositionedTile.new(tile("t"), [7, 7]),
          PositionedTile.new(tile("c"), [7, 9]),
          PositionedTile.new(tile("h"), [7, 10]),
        ]
        expect { subject.play!(player, tiles) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::GapError)
        end
        expect(board).to be_empty
      end

      it "should raise a relevant exception if it is not a real word" do
        tiles = [
          PositionedTile.new(tile("h"), [7, 5]),
          PositionedTile.new(tile("j"), [7, 6]),
          PositionedTile.new(tile("k"), [7, 7]),
        ]
        expect { subject.play!(player, tiles) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::NotAWordError)
        end
        expect(board).to be_empty
      end
    end

    context "making a move on an already populated board" do
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
        })
      end

      it "should raise a relevant exception if the tiles are not all in the same row or same column" do
        tiles = [
          PositionedTile.new(tile("p"), [3, 5]),
          PositionedTile.new(tile("r"), [3, 7]),
          PositionedTile.new(tile("r"), [3, 8]),
          PositionedTile.new(tile("o"), [3, 9]),
          PositionedTile.new(tile("t"), [4, 10]),
        ]
        expect { subject.play!(player, tiles) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::NotInSameRowOrSameColumnError)
        end
      end

      it "should raise a relevant exception if there is a gap in the word" do
        tiles = [
          PositionedTile.new(tile("p"), [3, 5]),
          PositionedTile.new(tile("r"), [3, 7]),
          PositionedTile.new(tile("r"), [3, 8]),
          PositionedTile.new(tile("o"), [3, 9]),
          PositionedTile.new(tile("t"), [3, 11]),
        ]
        expect { subject.play!(player, tiles) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::GapError)
        end
      end

      it "should raise a relevant exception if a non-real word is formed" do
        #forms DOG going down but DA going across
        tiles = [
          PositionedTile.new(tile("d"), [6, 5]),
          PositionedTile.new(tile("g"), [6, 7]),
        ]
        expect { subject.play!(player, tiles) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::NotAWordError)
        end
      end

      it "should raise a relevant exception if non of the existing words are used to make a new word" do
        #forms DOG going down but DA going across
        tiles = [
          PositionedTile.new(tile("d"), [0, 1]),
          PositionedTile.new(tile("o"), [0, 2]),
          PositionedTile.new(tile("g"), [0, 3]),
        ]
        expect { subject.play!(player, tiles) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::DidNotBuildOnExistingWordsError)
        end
      end
    end
  end

  describe "pass!" do
    context "when the current player is player1" do
      it "should cause the current player to be player2" do
        subject.pass!
        expect(subject.to_hash.fetch(:player)).to eq(:player2)
      end
    end

    context "when the current player is player2" do
      subject { Game.new(board, :player2) }

      it "should cause the current player to be player1" do
        subject.pass!
        expect(subject.to_hash.fetch(:player)).to eq(:player1)
      end
    end
  end
end
