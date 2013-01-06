class Wait
  class BaseRescuer
    def initialize(logger, *exceptions)
      @logger     = logger
      @exceptions = Array(exceptions).flatten
    end

    # Returns an array of the exceptions that ought to be rescued.
    def exceptions
      internal_exceptions + @exceptions
    end

    # Returns exceptions that are essential to internal operation of the Wait
    # gem.
    def internal_exceptions
      [TimeoutError]
    end

    # Returns +true+ if an exception can be ignored.
    def ignore?(exception)
      true
    end

    # Raises the exception given unless it can be ignored.
    def raise_unless_ignore(exception)
      log_exception(exception)
      raise(exception) unless ignore?(exception)
    end

    # Logs an exception.
    def log_exception(exception)
      @logger.debug "[Rescuer] rescued: #{exception.class.name}: #{exception.message}"
      @logger.debug exception.backtrace.join("\n")
    end
  end # BaseRescuer
end # Wait
