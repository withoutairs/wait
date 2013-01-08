class Wait
  class BaseRaiser
    def initialize(logger, exception)
      @logger    = logger
      @exception = exception
      log
    end

    # Returns +true+ if an exception ought to be raised.
    def raise?
      false
    end

    def log
      @logger.debug "[Raiser] raise? #{@exception.class.name}: #{raise?}"
    end
  end # BaseRaiser
end # Wait
