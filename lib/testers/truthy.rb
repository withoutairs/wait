class Wait
  class TruthyTester < BaseTester
    class ResultNotTruthy < RuntimeError; end

    # Returns an array of exceptions that ought to be rescued by the rescuer.
    def exceptions
      [ResultNotTruthy]
    end

    # Raises an exception unless the result is valid.
    def raise_unless_valid(result)
      log_result(result)
      valid?(result) ? result : raise(ResultNotTruthy, result.inspect)
    end

    # Returns +true+ if a result if valid.
    def valid?(result)
      not (result.nil? or result == false)
    end
  end # TruthyTester
end # Wait
