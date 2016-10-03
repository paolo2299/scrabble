module InvalidMove
  class FirstMoveNotOnCenterError < StandardError; end;
  class NotAWordError < StandardError; end;
  class NotInSameRowOrSameColumnError < StandardError; end;
  class GapError < StandardError; end;
  class DidNotBuildOnExistingWordsError < StandardError; end;
end
