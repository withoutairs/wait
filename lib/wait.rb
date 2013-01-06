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
  #   Wait::RegularDelayer.new.
  # [:rescue]
  #   One or an array of exceptions to rescue. Default is +nil+.
  # [:tester]
  #   Strategy to use to test the result. Default is Wait::TruthyTester.
  # [:logger]
  #   Ruby logger to use. Default is Wait#logger.
  #
  def initialize(options = {})
    @attempts   = options[:attempts] || 5
    @timeout    = options[:timeout]  || 15
    @delayer    = options[:delayer]  || RegularDelayer.new
    @exceptions = Array(options[:rescue])
    @tester     = options[:tester]   || TruthyTester
    @logger     = options[:logger]   || logger

    @counter = AttemptCounter.new(@attempts)

    validate_strategies
  end

  # Validates all of the assigned strategy objects.
  def validate_strategies
    StrategyValidator.new(:delayer, @delayer,    :sleep ).validate
    StrategyValidator.new(:tester,  @tester,     :new   ).validate
    StrategyValidator.new(:tester,  @tester.new, :valid?).validate
  end

  # Returns a new (or existing) logger instance.
  def logger
    if @logger.nil?
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::WARN
    end

    @logger
  end

  # == Description
  #
  # Wait#until executes a block until there's a valid (by default, truthy)
  # result. Useful for blocking script execution until:
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
  #   # Rescued exception while waiting: Wait::TruthyTester::ResultNotTruthy: false
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
  #   # Rescued exception while waiting: Wait::TruthyTester::ResultNotTruthy: nil
  #   # Attempt 1/5 failed, delaying for 1s
  #   # Rescued exception while waiting: RuntimeError: RuntimeError
  #   # Attempt 2/5 failed, delaying for 2s
  #   # => "foo"
  #
  # == Returns
  #
  # The result of the block if valid (by default, truthy).
  #
  # == Raises
  #
  # If no results are valid, the exception from the last attempt made.
  #
  def until(&block)
    # Reset the attempt counter.
    @counter.reset

    begin
      @counter.increment

      result = Timeout.timeout(@timeout, Wait::TimeoutError) do
        # Execute the block and pass the attempt count to it.
        yield(@counter.attempt)
      end

      tester = @tester.new(result)
      tester.raise_unless_valid
    rescue Wait::TimeoutError, *(@tester.exceptions + @exceptions) => exception
      logger.debug "Rescued exception while waiting: #{exception.class.name}: #{exception.message}"
      logger.debug exception.backtrace.join("\n")

      # If this was the last attempt, raise the exception from the last
      # attempt.
      if @counter.last_attempt?
        raise(exception)
      else
        logger.debug "Attempt #{@counter} failed, delaying for #{@delayer}"
        @delayer.sleep
        retry
      end
    end
  end

  # Raised when a block times out.
  class TimeoutError < Timeout::Error; end
end #Wait

require_relative "attempt_counter"
require_relative "strategy_validator"
require_relative "delayers/regular"
require_relative "delayers/exponential"
require_relative "testers/truthy"
