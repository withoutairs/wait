class Wait
  class BaseRaiser
    attr_accessor :logger

    # Returns +true+ if an exception ought to be raised.
    def raise?(exception)
      false.tap do |raising|
        log(exception, raising)
      end
    end

    def log(exception, raising)
      return if @logger.nil?

      @logger.debug("Raiser") { "#{"not " unless raising}raising: #{exception.class.name}" }
    end
  end # BaseRaiser
end # Wait
