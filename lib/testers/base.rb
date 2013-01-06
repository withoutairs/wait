class Wait
  class BaseTester
    # Returns an array of exceptions that ought to be rescued by the rescuer.
    def exceptions
      []
    end

    def initialize(logger)
      @logger = logger
    end

    # Raises an exception unless the result is valid.
    def raise_unless_valid(result)
      log_result
      valid?(result)
    end

    # Returns +true+ if a result if valid.
    def valid?(result)
      true
    end

    # Logs a result.
    def log_result(result)
      @logger.debug "[Tester] result: #{result.inspect}"
    end
  end # BaseTester
end # Wait
