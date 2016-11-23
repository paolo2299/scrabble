class InvalidMove < StandardError
  def initialize(message="", data={})
    @message = message
    @data = data
  end

  def data
    @data.merge({
      type: name
    })
  end

  def name
    self.class.name.split("::").last
  end

  class FirstMoveNotOnCenterError < InvalidMove; end;
  class InvalidWordError < InvalidMove; end;
  class NotInSameRowOrSameColumnError < InvalidMove; end;
  class GapError < InvalidMove; end;
  class DidNotBuildOnExistingWordsError < InvalidMove; end;
end
