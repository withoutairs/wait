class Wait
  class SignalRaiser < BaseRaiser
    def raise?(exception)
      signal_exception?(exception.class).tap do |raising|
        log(exception, raising)
      end
    end

    # Returns +true+ if an exception raised is a signal exception.
    def signal_exception?(klass)
      [SignalException, Interrupt, NoMemoryError, SystemExit].include?(klass)
    end
  end # SignalRaiser
end # Wait
