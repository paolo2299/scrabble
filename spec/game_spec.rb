require 'spec_helper'
require 'board'
require 'game'

describe Game do
  let(:board) { instance_double(Board) }
  subject { Game.new(board, Tileset.standard_tileset) }

  describe "play_tiles!" do
    context "making the first move of the game" do
      it "should raise a relevant exception if it is not a real word" do
        tiles = [
          PositionedTile.new("h", [5, 5]),
          PositionedTile.new("j", [5, 6]),
          PositionedTile.new("k", [5, 7]),
        ]
        expect { subject.play_tiles!(tiles) }.to raise_error do |error|
          expect(error).to be_a(InvalidMove::NotAWordError)
        end
      end
    end
  end
end
