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
    let(:tiles) { [] }
    let(:positions) { [] }
    let(:board) { Board.load_from_string!(board_string) }
    subject { described_class.new(tiles, positions, board) }

    before do
      tiles.zip(positions).each do |tile, position|
        if board.tile(position).nil?
          board.place_tile!(tile, position)
        end
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

    context "with a populated board" do
      let(:board_string) do
        %Q{
---------------
---------------
---------------
---------------
-------E-------
WILLFULL-------
-------O-------
-------Q-------
-------U-------
------PENITENT-
-------N----O--
-------T----G--
------------G--
------------I--
------------N--
        }
      end

      context "an existing letter is on a multiplier but all new letters have no multiplier" do
        let(:tiles) { generate_tiles("EQUAL") }
        let(:positions) { [[6, 7], [7, 7], [8, 7], [9, 7], [10, 7]] }
        # results in
        # ---------------
        # ---------------
        # ---------------
        # ---------------
        # -------E-------
        # WILLFULL-------
        # -------O-------
        # ------eQual----
        # -------U-------
        # ------PENITENT-
        # -------N----O--
        # -------T----G--
        # ------------G--
        # ------------I--
        # ------------N--
        # where the existing Q is on a double word score

        it "should give the correct score" do
          # (E = 1) + (Q = 10) + (U = 1) + (A = 1) + (L = 1) = 14
          expect(subject.score).to eq(14)
        end
      end

      context "placing a word on a double letter and a triple word score" do
        let(:tiles) { generate_tiles("SNUG") }
        let(:positions) { [[11, 14], [12, 14], [13, 14], [14, 14]] }
        # results in
        # ---------------
        # ---------------
        # ---------------
        # ---------------
        # -------E-------
        # WILLFULL-------
        # -------O-------
        # -------Q-------
        # -------U-------
        # ------PENITENT-
        # -------N----O--
        # -------T----G--
        # ------------G--
        # ------------I--
        # -----------sNug
        # where the s of snug is on a double letter score
        # and the g is on a triple word score

        it "should give the correct score" do
          # ((S = 1) * 2 + (N = 1) + (U = 1) + (G = 2)) * 3 = 18
          expect(subject.score).to eq(18)
        end
      end

      context "placing a word on a triple letter and triple word score" do
        let(:tiles) { generate_tiles("PRAISE") }
        let(:positions) { [[9, 13], [10, 13], [11, 13], [12, 13], [13, 13], [14, 13]] }
        # results in
        # ---------------
        # ---------------
        # ---------------
        # ---------------
        # -------E-------
        # WILLFULL-------
        # -------O-------
        # -------Q-------
        # -------U-------
        # ------PENITENT-
        # -------N----O--
        # -------T----G--
        # ------------G--
        # ---------praIse
        # ------------N--
        # where the p of praise is on a triple letter score
        # and the s is on a double word score

        it "should give the correct score" do
          # ((P = 3) * 3 + (R = 1) + (A = 1) + (I = 1) + (S = 1) + (E = 1)) * 2 = 28
          expect(subject.score).to eq(28)
        end
      end
    end
  end
end
