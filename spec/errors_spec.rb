require 'spec_helper'
require 'errors'

describe "errors" do
  describe "error_type" do
    it "should be the name of the parent error class" do
      error = GameError::PlayerNotFoundError.new(some: :data)
      expect(error.error_type).to eq("GameError")
    end
  end

  describe "error_sub_type" do
    it "should be the name of the child subclass" do
      error = InvalidMoveError::FirstMoveNotOnCenterError.new(some: :data)
      expect(error.error_sub_type).to eq("FirstMoveNotOnCenterError")
    end
  end
end
