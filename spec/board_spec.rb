require 'spec_helper'
require 'board'
require 'played_word'
require 'tile'
require 'tile_bag'

describe Board do

  def tile(letter)
    tile_bag = TileBag.new_tile_bag
    tile_bag.take_tile_with_letter!(letter)
  end

  def tiles(string)
    string.chars.map{|c| tile(c)}
  end

  subject { Board.new_board }

  describe ".load_from_string!" do
    it "should load the stirng correctly" do
      string = %Q{
--C------------
-PARROT--------
--T------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
      }
      board = Board.load_from_string!(string)
      expect(board.to_s).to eq(string.strip)
    end
  end

  describe "empty?" do
    it "should return true for an empty board" do
      expect(subject.empty?).to eq(true)
    end

    it "should return false if a tile has been played" do
      subject.place_tile!(tile("Q"), [2, 2])
      expect(subject.empty?).to eq(false)
    end
  end

  describe "tile" do
    it "should return the correct tile for the specified position" do
      subject.place_tile!(tile("Q"), [2, 3])
      expect(subject.tile([2, 3]).letter).to eq("Q")
      expect(subject.tile([2, 4])).to be_nil
    end
  end

  describe "place_tile!" do
    context "with an empty board" do
      it "should place the tile in the correct place" do
        subject.place_tile!(tile("Q"), [2, 1])
        expected = %Q{
---------------
--Q------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
        }.strip
        expect(subject.to_s).to eq(expected)
      end

      it "should raise an error if a tile is placed off the right side of the board" do
        expect { subject.place_tile!(tile("Q"), [15, 0]) }.to raise_error do |error|
          expect(error).to be_a Board::InvalidTilePlacementError
          expect(error.message).to match("column index 15 is not between 0 and 14")
        end
      end

      it "should raise an error if a tile is placed off the left side of the board" do
        expect { subject.place_tile!(tile("Q"), [-1, 0]) }.to raise_error do |error|
          expect(error).to be_a Board::InvalidTilePlacementError
          expect(error.message).to match("column index -1 is not between 0 and 14")
        end
      end

      it "should raise an error if a tile is placed off the bottom of the board" do
        expect { subject.place_tile!(tile("Q"), [0, 15]) }.to raise_error do |error|
          expect(error).to be_a Board::InvalidTilePlacementError
          expect(error.message).to match("row index 15 is not between 0 and 14")
        end
      end

      it "should raise an error if a tile is placed off the top of the board" do
        expect { subject.place_tile!(tile("Q"), [0, -1]) }.to raise_error do |error|
          expect(error).to be_a Board::InvalidTilePlacementError
          expect(error.message).to match("row index -1 is not between 0 and 14")
        end
      end
    end

    context "with a populated board" do
      let(:board_string) do
        %Q{
--C------------
-PARROT--------
--T------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
        }
      end

      subject { Board.load_from_string!(board_string) }

      it "should place the tile in the correct place and keep the existing tiles" do
        subject.place_tile!(tile("Q"), [4, 5])
        expected = %Q{
--C------------
-PARROT--------
--T------------
---------------
---------------
----Q----------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
        }.strip
        expect(subject.to_s).to eq(expected)
      end

      it "should raise an error if a tile is placed on an exiting tile" do
        expect { subject.place_tile!(tile("Q"), [2, 0]) }.to raise_error do |error|
          expect(error).to be_a Board::InvalidTilePlacementError
          expect(error.message).to eq("there is already a tile at position [2, 0]")
        end
      end
    end
  end

  describe "copy" do

    subject do
      string = %Q{
--C------------
-PARROT--------
--T------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
        }
      Board.load_from_string!(string)
    end

    it "should return a board that is identical to the original" do
      subject_copy = subject.copy
      expect(subject_copy.to_s).to eq(subject.to_s)
    end

    it "should return a board that can be edited independently of the original" do
      old_subject_string = subject.to_s
      subject_copy = subject.copy
      subject_copy.place_tile!(tile("Q"), [0, 0])
      expect(subject_copy.to_s).to_not eq(old_subject_string)
      expect(subject.to_s).to eq(old_subject_string)
    end
  end

  describe "all_played_words" do

    subject do
      string = %Q{
--C--S---------
-PARROT--------
-IT-A-AS-------
--E-M-R--------
-ARMPIT--------
---OAT---------
----R----------
----T----------
---------------
---------------
---------------
---------------
---------------
---------------
---------------
      }
      Board.load_from_string!(string)
    end

    it "should return all words" do
      board = Board.new_board

      expect(subject.all_played_words).to eq([
        PlayedWord.new(
          tiles("PARROT"),
          [
            [1, 1],
            [2, 1],
            [3, 1],
            [4, 1],
            [5, 1],
            [6, 1]
          ],
          board
        ),
        PlayedWord.new(
          tiles("IT"),
          [
            [1, 2],
            [2, 2]
          ],
          board
        ),
        PlayedWord.new(
          tiles("AS"),
          [
            [6, 2],
            [7, 2]
          ],
          board
        ),
        PlayedWord.new(
          tiles("ARMPIT"),
          [
            [1, 4],
            [2, 4],
            [3, 4],
            [4, 4],
            [5, 4],
            [6, 4]
          ],
          board
        ),
        PlayedWord.new(
          tiles("OAT"),
          [
            [3, 5],
            [4, 5],
            [5, 5]
          ],
          board
        ),
        PlayedWord.new(
          tiles("PI"),
          [
            [1, 1],
            [1, 2]
          ],
          board
        ),
        PlayedWord.new(
          tiles("CATER"),
          [
            [2, 0],
            [2, 1],
            [2, 2],
            [2, 3],
            [2, 4]
          ],
          board
        ),
        PlayedWord.new(
          tiles("MO"),
          [
            [3, 4],
            [3, 5]
          ],
          board
        ),
        PlayedWord.new(
          tiles("RAMPART"),
          [
            [4, 1],
            [4, 2],
            [4, 3],
            [4, 4],
            [4, 5],
            [4, 6],
            [4, 7]
          ],
          board
        ),
        PlayedWord.new(
          tiles("SO"),
          [
            [5, 0],
            [5, 1]
          ],
          board
        ),
        PlayedWord.new(
          tiles("IT"),
          [
            [5, 4],
            [5, 5]
          ],
          board
        ),
        PlayedWord.new(
          tiles("TART"),
          [
            [6, 1],
            [6, 2],
            [6, 3],
            [6, 4]
          ],
          board
        ),
      ])
    end
  end

  describe "has_adjacent_tiles?" do
    let(:board_string) do
      %Q{
-C---S---------
PARROT---------
-N---R---------
-----A---------
-----T--L------
----CARTON-----
--------T------
--------T------
--------E------
-------GRIT----
--------Y-O----
----------N----
----------G----
----------U----
--------BREADED
      }
    end

    subject { Board.load_from_string!(board_string) }

    it "should return true if there is an adjacent square with a tile, false otherwise" do
      expect(subject.has_adjacent_tiles?([0, 0])).to eq(true)
      expect(subject.has_adjacent_tiles?([0, 10])).to eq(false)
      expect(subject.has_adjacent_tiles?([10, 5])).to eq(true)
      expect(subject.has_adjacent_tiles?([10, 6])).to eq(false)
      expect(subject.has_adjacent_tiles?([14, 13])).to eq(true)
    end
  end
end
