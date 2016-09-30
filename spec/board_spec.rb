require 'spec_helper'
require 'board'
require 'tileset'

describe Board do
  subject { Board.new(width: 10, height: 8) }
  let(:tileset) { Tileset.standard_tileset }

  describe "load_from_string!" do
    it "should load the stirng correctly" do
      string = %Q{
--C-------
-PARROT---
--T-------
----------
----------
----------
----------
----------
      }
      subject.load_from_string!(string, tileset)
      expect(subject.to_s).to eq(string.strip)
    end
  end

  describe "place_tile!" do
    context "with an empty board" do
      it "should place the tile in the correct place" do
        tile_Q = tileset.tile("Q")
        position = [2 ,1]
        subject.place_tile!(tile_Q, position)
        expected = %Q{
----------
--Q-------
----------
----------
----------
----------
----------
----------
        }.strip
        expect(subject.to_s).to eq(expected)
      end

      it "should raise an error if a tile is placed off the right side of the board" do
        tile_Q = tileset.tile("Q")
        position = [10, 0]
        expect { subject.place_tile!(tile_Q, position) }.to raise_error do |error|
          expect(error).to be_a Board::InvalidTilePlacementError
          expect(error.message).to match("column index 10 is not between 0 and 9")
        end
      end

      it "should raise an error if a tile is placed off the left side of the board" do
        tile_Q = tileset.tile("Q")
        position = [-1, 0]
        expect { subject.place_tile!(tile_Q, position) }.to raise_error do |error|
          expect(error).to be_a Board::InvalidTilePlacementError
          expect(error.message).to match("column index -1 is not between 0 and 9")
        end
      end

      it "should raise an error if a tile is placed off the bottom of the board" do
        tile_Q = tileset.tile("Q")
        position = [0, 8]
        expect { subject.place_tile!(tile_Q, position) }.to raise_error do |error|
          expect(error).to be_a Board::InvalidTilePlacementError
          expect(error.message).to match("row index 8 is not between 0 and 7")
        end
      end

      it "should raise an error if a tile is placed off the top of the board" do
        tile_Q = tileset.tile("Q")
        position = [0, -1]
        expect { subject.place_tile!(tile_Q, position) }.to raise_error do |error|
          expect(error).to be_a Board::InvalidTilePlacementError
          expect(error.message).to match("row index -1 is not between 0 and 7")
        end
      end
    end

    context "with a populated board" do
      before do
        string = %Q{
--C-------
-PARROT---
--T-------
----------
----------
----------
----------
----------
        }
        subject.load_from_string!(string, tileset)
      end

      it "should place the tile in the correct place and keep the existing tiles" do
        tile_Q = tileset.tile("Q")
        position = [4, 5]
        subject.place_tile!(tile_Q, position)
        expected = %Q{
--C-------
-PARROT---
--T-------
----------
----------
----Q-----
----------
----------
        }.strip
        expect(subject.to_s).to eq(expected)
      end

      it "should raise an error if a tile is placed on an exiting tile" do
        tile_Q = tileset.tile("Q")
        position = [2, 0]
        expect { subject.place_tile!(tile_Q, position) }.to raise_error do |error|
          expect(error).to be_a Board::InvalidTilePlacementError
          expect(error.message).to eq("there is already a tile at position [2, 0]")
        end
      end
    end
  end

  describe "copy" do
    before do
      string = %Q{
--C-------
-PARROT---
--T-------
----------
----------
----------
----------
----------
        }
      subject.load_from_string!(string, tileset)
    end

    it "should return a board that is identical to the original" do
      subject_copy = subject.copy
      expect(subject_copy.to_s).to eq(subject.to_s)
    end

    it "should return a board that can be edited independently of the original" do
      old_subject_string = subject.to_s
      subject_copy = subject.copy
      subject_copy.place_tile!
      expect(subject_copy.to_s).to eq(subject.to_s)
      blah
    end
  end

  describe "all_played_words" do
    it "should return all words" do
      string = %Q{
--C--S----
-PARROT---
-IT-A-AS--
--E-M-R---
-ARMPIT---
---OAT----
----R-----
----T-----
      }
      subject.load_from_string!(string, tileset)
      expect(subject.all_played_words).to eq([
        PlayedWord.new("PARROT", [1, 1], :across),
        PlayedWord.new("IT", [1, 2], :across),
        PlayedWord.new("AS", [6, 2], :across),
        PlayedWord.new("ARMPIT", [1, 4], :across),
        PlayedWord.new("OAT", [3, 5], :across),
        PlayedWord.new("PI", [1, 1], :down),
        PlayedWord.new("CATER", [2, 0], :down),
        PlayedWord.new("MO", [3, 4], :down),
        PlayedWord.new("RAMPART", [4, 1], :down),
        PlayedWord.new("SO", [5, 0], :down),
        PlayedWord.new("IT", [5, 4], :down),
        PlayedWord.new("TART", [6, 1], :down)
      ])
    end
  end
end
