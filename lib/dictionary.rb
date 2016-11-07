class Dictionary
  FILEPATH = "data/words.txt"

  def self.valid_word?(word)
    words.include?(word.upcase)
  end

  private

  def self.words
    @words ||= begin
      IO.readlines(FILEPATH).map(&:strip).map(&:upcase)
    end
  end
end
