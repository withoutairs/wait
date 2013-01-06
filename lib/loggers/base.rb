class Wait
  class BaseLogger
    extend Forwardable

    attr_reader :logger
    def_delegators :logger, :fatal,
                           :error,
                           :warn,
                           :info,
                           :debug

    def initialize
      @logger       = ::Logger.new(STDOUT)
      @logger.level = level
    end

    def level
      ::Logger::WARN
    end
  end # Logger
end # Wait
