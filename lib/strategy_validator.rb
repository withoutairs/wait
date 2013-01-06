class Wait
  class StrategyValidator
    def initialize(strategy, klass, message)
      @strategy = strategy
      @klass    = klass
      @message  = message
    end

    def validate
      unless @klass.respond_to?(@message)
        raise(ArgumentError, "#{@strategy} strategy #{@klass.inspect} does not respond to :#{@message} message")
      end
    end
  end #StrategyValidator
end #Wait
