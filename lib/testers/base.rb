class Wait
  class BaseTester
    attr_accessor :logger

    # Returns +true+ if a result if valid.
    def valid?(result)
      log(result)

      true
    end

    def log(result)
      return if @logger.nil?

      @logger.debug("Tester") { "result: #{result.inspect}" }
    end
  end # BaseTester
end # Wait
