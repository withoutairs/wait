class Wait
  class BaseDelayer
    def initialize(logger, initial_delay)
      @logger = logger
      @delay  = initial_delay
    end

    # Called before a reattempt to sleep a certain about of time.
    def sleep
      log_delay
      Kernel.sleep(@delay)
    end

    # Logs how long the delay is.
    def log_delay
      @logger.debug "[Delayer] delaying for #{self}"
    end

    # Returns a string representation of the delay.
    def to_s
      "#{@delay}s"
    end
  end # BaseDelayer
end # Wait
