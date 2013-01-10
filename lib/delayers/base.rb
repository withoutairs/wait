class Wait
  class BaseDelayer
    attr_accessor :logger

    def initialize(delay)
      @delay = delay
    end

    # Called before a reattempt to sleep a certain about of time.
    def sleep
      log
      Kernel.sleep(@delay)
    end

    # Logs how long the delay is.
    def log
      return if @logger.nil?

      @logger.debug("Delayer") { "delaying for #{self}" }
    end

    # Returns a string representation of the delay.
    def to_s
      "#{@delay}s"
    end
  end # BaseDelayer
end # Wait
