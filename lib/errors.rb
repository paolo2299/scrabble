class InvalidMove < StandardError
  attr_reader :data

  def initialize(message="", data={})
    @message = message
    @data = data
  end

  class FirstMoveNotOnCenterError < InvalidMove; end;
  class InvalidWordError < InvalidMove; end;
  class NotInSameRowOrSameColumnError < InvalidMove; end;
  class GapError < InvalidMove; end;
  class DidNotBuildOnExistingWordsError < InvalidMove; end;
end
