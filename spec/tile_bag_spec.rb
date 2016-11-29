require 'spec_helper'
require 'tile_bag'

describe TileBag do
  subject { TileBag.new_tile_bag }

  it "should have the correct number of tiles" do
    #TODO this should go up to 100 once blank tiles are introduced
    expect(subject.count).to eq(98)
  end

  describe "random_draw!" do
    it "should return the correct number of tiles" do
      tiles = subject.random_draw!(2)
      expect(tiles.count).to eq(2)
      expect(tiles[0]).to be_a(Tile)
      expect(tiles[1]).to be_a(Tile)
    end

    it "should remove the tiles from the bag" do
      tiles = subject.random_draw!(2)
      expect(subject).to_not include(tiles[0])
      expect(subject).to_not include(tiles[1])
    end

    it "should randomise the tiles it returns" do
      tiles1 = TileBag.new_tile_bag.random_draw!(5)
      tiles2 = TileBag.new_tile_bag.random_draw!(5)
      expect(tiles1.map(&:id)).to_not eq(tiles2.map(&:id))
    end
  end
end
