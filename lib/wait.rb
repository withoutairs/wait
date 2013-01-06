require "timeout"
require "logger"

require_relative "attempt_counter"
require_relative "delayers/regular"
require_relative "delayers/exponential"
require_relative "testers/truthy"

class Wait
  class Logger
    attr_reader :logger

    def initialize
      @logger       = ::Logger.new(STDOUT)
      @logger.level = ::Logger::WARN
    end
  end # Logger

  DEFAULT = {
    :attempts => 5,
    :timeout  => 15,
    :delay    => 1,
    :delayer  => RegularDelayer,
    :tester   => TruthyTester,
    :logger   => Logger
  }

  # Creates a new Wait instance.
  #
  # == Options
  #
  # [:attempts]
  #   Number of times to attempt the block. Default is +5+.
  # [:timeout]
  #   Seconds until the block times out. Default is +15+.
  # [:delay]
  #   Seconds to delay in between attempts. Passed to +delayer+. Default is
  #   +1+.
  # [:delayer]
  #   Delay strategy used to sleep in between attempts. Default is
  #   Wait::RegularDelayer.
  # [:rescue]
  #   One or an array of exceptions to rescue. Default is +nil+.
  # [:tester]
  #   Strategy used to test the result. Default is Wait::TruthyTester.
  # [:logger]
  #   Ruby logger used. Default is Wait::Logger.
  #
  def initialize(options = {})
    attempts    = options[:attempts]           || DEFAULT[:attempts]
    @counter    = AttemptCounter.new(attempts)
    @timeout    = options[:timeout]            || DEFAULT[:timeout]
    delay       = options[:delay]              || DEFAULT[:delay]
    @delayer    = (options[:delayer]           || DEFAULT[:delayer]).new(delay)
    @exceptions = Array(options[:rescue])
    @tester     = options[:tester]             || DEFAULT[:tester]
    @logger     = (options[:logger]            || DEFAULT[:logger]).new
  end

  def logger
    @logger.logger
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
