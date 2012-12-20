require "timeout"
require "logger"

class Wait
  # Creates a new Wait instance.
  #
  # == Options
  #
  # [:attempts]
  #   Number of times to attempt the block. Default is +5+.
  # [:timeout]
  #   Seconds until the block times out. Default is +15+.
  # [:delayer]
  #   Delay strategy to use to sleep in between attempts. Default is
  #   +Wait::RegularDelayer.new+.
  # [:rescue]
  #   One or an array of exceptions to rescue. Default is +nil+.
  # [:debug]
  #   If +true+, logs debugging output. Default is +false+.
  #
  def initialize(options = {})
    @attempts   = options[:attempts] || 5
    @timeout    = options[:timeout]  || 15
    @delayer    = options[:delayer]  || RegularDelayer.new
    @exceptions = options[:rescue]
    debug       = options[:debug]    || false

    @counter = AttemptCounter.new(@attempts)

    unless @delayer.respond_to?(:sleep)
      raise(ArgumentError, "delay strategy does not respond to sleep message: #{@delayer.inspect}")
    end

    @logger = Logger.new(STDOUT)
    @logger.level = debug ? Logger::DEBUG : Logger::WARN
  end

  # == Description
  #
  # Wait#until executes a block until there's a result. Useful for blocking
  # script execution until:
  # * an HTTP request was successful
  # * a port has opened
  # * an external process has started
  # * etc.
  #
  # == Examples
  #
  #   wait = Wait.new
  #   # => #<Wait>
  #   wait.until { Time.now.sec.even? }
  #   # Rescued exception while waiting: Wait::NoResultError: result was false
  #   # Attempt 1/5 failed, delaying for 1s
  #   # => true
  #
  # If you wish to handle an exception by attempting the block again, pass one
  # or an array of exceptions with the +:rescue+ option.
  #
  #   wait = Wait.new(:rescue => RuntimeError)
  #   # => #<Wait>
  #   wait.until do |attempt|
  #     case attempt
  #     when 1 then nil
  #     when 2 then raise RuntimeError
  #     when 3 then "foo"
  #     end
  #   end
  #   # Rescued exception while waiting: Wait::NoResultError: result was nil
  #   # Attempt 1/5 failed, delaying for 1s
  #   # Rescued exception while waiting: RuntimeError: RuntimeError
  #   # Attempt 2/5 failed, delaying for 2s
  #   # => "foo"
  #
  # == Returns
  #
  # The result of the block if not +nil+ or +false+.
  #
  # == Raises
  #
  # The exception from the last attempt made.
  #
  def until(&block)
    # Reset the attempt counter.
    @counter.reset

    begin
      @counter.increment

      result = Timeout.timeout(@timeout, Wait::TimeoutError) do
        # Execute the block and pass the attempt value to it.
        yield(@counter.attempt)
      end

      # If there's a result (neither +nil+ or +false+), return the result.
      # Otherwise, raise a +Wait::NoResultError+ exception.
      if result
        result
      else
        raise(Wait::NoResultError, "result was #{result.inspect}")
      end
    rescue Wait::TimeoutError, Wait::NoResultError, *@exceptions => exception
      @logger.debug "Rescued exception while waiting: #{exception.class.name}: #{exception.message}"
      @logger.debug exception.backtrace.join("\n")

      # If this was the last attempt, raise the exception from the last
      # attempt.
      if @counter.last_attempt?
        raise(exception)
      else
        @logger.debug "Attempt #{@counter} failed, delaying for #{@delayer}"
        @delayer.sleep
        retry
      end
    end
  end

  # Raised when a block doesn't return a result (+nil+ or +false+).
  class NoResultError < StandardError; end

  # Raised when a block times out.
  class TimeoutError < Timeout::Error; end

  class RegularDelayer
    def initialize(initial_delay = 1)
      @delay = initial_delay
    end

    def sleep
      Kernel.sleep(@delay)
    end

    def to_s
      "#{@delay}s"
    end
  end # RegularDelayer

  class ExponentialDelayer < RegularDelayer
    def sleep
      super
      increment
    end

    def increment
      @delay *= 2
    end
  end # ExponentialDelayer

  class AttemptCounter
    attr_reader :attempt

    def initialize(total)
      # Prevent accidentally causing an infinite loop.
      unless total.is_a?(Fixnum) and total > 0
        raise(ArgumentError, "invalid number of attempts: #{total.inspect}")
      end

      @total = total
      reset
    end

    def reset
      @attempt = 0
    end

    def increment
      @attempt += 1
    end

    def last_attempt?
      @attempt == @total
    end

    def to_s
      [@attempt, @total].join("/")
    end
  end # AttemptCounter
end #Wait