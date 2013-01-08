class Wait
  class BaseTester
    def initialize(logger, result)
      @logger = logger
      @result = result
      log
    end

    # Returns +true+ if a result if valid.
    def valid?
      true
    end

    def log
      @logger.debug "[Tester] result: #{@result.inspect}"
    end
  end # BaseTester
end # Wait
