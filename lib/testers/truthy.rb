class Wait
  class TruthyTester
    class ResultNotTruthy < RuntimeError; end

    def self.exceptions
      [ResultNotTruthy]
    end

    def initialize(result = nil)
      @result = result
    end

    def raise_unless_valid
      valid? ? @result : raise(ResultNotTruthy, @result.inspect)
    end

    def valid?
      not (@result.nil? or @result == false)
    end
  end # TruthyTester
end # Wait
