class Wait
  class SignalRaiser < BaseRaiser
    def raise?
      signal_exception?(@exception.class)
    end

    # Returns +true+ if an exception raised is a signal exception.
    def signal_exception?(klass)
      klass.ancestors.include?(SignalException) or [NoMemoryError, SystemExit].include?(klass)
    end
  end # SignalRaiser
end # Wait
