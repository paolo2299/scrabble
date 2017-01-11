require 'spec_helper'
require 'board'
require 'played_word'
require 'tile'
require 'tile_bag'

describe PlayedWord do
  def generate_tile(letter)
    tile_bag = TileBag.new_tile_bag
    tile_bag.take_tile_with_letter!(letter)
  end

  def generate_tiles(string)
    string.chars.map{|c| generate_tile(c)}
  end

  describe ".to_s" do
    it "should return the correct string" do
      tiles = generate_tiles("CAT")
      positions = [[1, 2], [1, 3], [1, 4]]
      board = Board.new_board
      expect(described_class.new(tiles, positions, board).to_s).to eq("CAT")
    end
  end

  describe "equality" do
    it "should be equal with the same word and same positions" do
      tiles = generate_tiles("CAT")
      positions = [[1, 1], [1, 2], [1, 3]]
      board = Board.new_board
      played_word_1 = described_class.new(tiles, positions, board)
      played_word_2 = described_class.new(tiles, positions, board)
      expect(played_word_1).to eq(played_word_2)
    end

    it "should not be equal with the same word but different positions" do
      tiles = generate_tiles("CAT")
      board = Board.new_board
      played_word_1 = described_class.new(tiles, [[1, 1], [1, 2], [1, 3]], board)
      played_word_2 = described_class.new(tiles, [[2, 1], [2, 2], [2, 3]], board)
      expect(played_word_1).to_not eq(played_word_2)
    end

    it "should not be equal with a different word but the same positions" do
      positions = [[1, 1], [1, 2], [1, 3]]
      board = Board.new_board
      played_word_1 = described_class.new(generate_tiles("CAT"), positions, board)
      played_word_2 = described_class.new(generate_tiles("MAT"), positions, board)
      expect(played_word_1).to_not eq(played_word_2)
    end
  end

  describe ".score" do
    let(:board_string) do
      %Q{
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
---------------
---------------
      }
    end
    let(:positions) { [] }
    let(:tiles) { [] }
    let(:board) { Board.load_from_string!(board_string) }
    subject { described_class.new(tiles, positions, board) }

    before do
      positions.each do |position|
        expect(board).to receive(:newly_played_tile?).with(position).and_return(true)
      end
    end

    context "making a first move on the centre square" do
      let(:tiles) { generate_tiles("CAT") } # normally scores 3 + 1 + 1 = 5
      let(:positions) { [
        [7, 6],
        [7, 7], #centre square
        [7, 8]
      ] }

      it "should score double" do
        expect(subject.score).to eq(10)
      end
    end
  end
end
