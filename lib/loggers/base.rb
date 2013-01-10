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
      @logger           = ::Logger.new(STDOUT)
      @logger.level     = level
      @logger.formatter = formatter
    end

    def level
      ::Logger::WARN
    end

    def formatter
      proc do |severity, datetime, program_name, message|
        [severity.ljust(5), message].join(" ") + "\n"
      end
    end

    def backtrace(backtrace)
      backtrace.map { |line| (" " * 25) + line }.join("\n")
    end
  end # Logger
end # Wait
