class ScrabbleError < StandardError
  attr_reader :data

  def initialize(message="", data={})
    @message = message
    @data = data
  end

  def error_type
    self.class.name.split("::").first
  end

  def error_sub_type
    self.class.name.split("::").last
  end
end

class InvalidMoveError < ScrabbleError
  class FirstMoveNotOnCenterError < InvalidMoveError; end;
  class InvalidWordError < InvalidMoveError; end;
  class NotInSameRowOrSameColumnError < InvalidMoveError; end;
  class GapError < InvalidMoveError; end;
  class DidNotBuildOnExistingWordsError < InvalidMoveError; end;
end

class GameError < ScrabbleError
  class GameNotFoundError < GameError; end;
  class TooManyPlayersError < GameError; end;
  class PlayerNotFoundError < GameError; end;
  class PlayerActedOutOfTurnError < GameError; end;
  class GameNotInProgressError < GameError; end;
end

class GameInitialisationError < ScrabbleError
  class NameNotProvidedError < GameError; end;
  class GameNotFoundError < GameError; end;
  class GameFullError < GameError; end;
end
