class Wait
  class BaseRescuer
    attr_reader :exceptions

    def initialize(logger, *exceptions)
      @logger     = logger
      @exceptions = Array(exceptions).flatten
    end

    # Logs an exception.
    def log(exception)
      @logger.debug "[Rescuer] rescued: #{exception.class.name}: #{exception.message}\n#{@logger.backtrace(exception.backtrace)}"
    end
  end # BaseRescuer
end # Wait
