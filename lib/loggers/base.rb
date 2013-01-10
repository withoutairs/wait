class Wait
  class BaseLogger
    extend Forwardable

    attr_reader    :logger
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
      proc do |severity, datetime, caller, message|
        "#{severity.ljust(5)} #{"[#{caller}]".ljust(9)} #{message}\n"
      end
    end

    def indent(lines, spaces = 25)
      lines.map { |line| (" " * spaces) + line }.join("\n")
    end
  end # Logger
end # Wait
