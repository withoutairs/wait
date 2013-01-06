require File.expand_path("../initialize", __FILE__)

class Wait
  DEFAULT = {
    :timeout  => 15,
    :logger   => BaseLogger,
    :attempts => 5,
    :counter  => BaseCounter,
    :delay    => 1,
    :delayer  => RegularDelayer,
    :tester   => TruthyTester,
    :rescuer  => PassiveRescuer
  }

  # Creates a new Wait instance.
  #
  # == Options
  #
  # [:attempts]
  #   Number of times to attempt the block (passed to +counter+). Default is
  #   +5+.
  # [:counter]
  #   Strategy used to count attempts. Default is Wait::BaseCounter.
  # [:timeout]
  #   Seconds until the block times out. Default is +15+.
  # [:delay]
  #   Seconds to delay in between attempts (passed to +delayer+). Default is
  #   +1+.
  # [:delayer]
  #   Strategy used to delay in between attempts. Default is
  #   Wait::RegularDelayer.
  # [:rescue]
  #   One or an array of exceptions to rescue (passed to +rescuer+). Default
  #   is +nil+.
  # [:rescuer]
  #   Strategy used to handle exceptions. Default is Wait::PassiveRescuer.
  # [:tester]
  #   Strategy used to test the result. Default is Wait::TruthyTester.
  # [:logger]
  #   Ruby logger used. Default is Wait::BaseLogger.
  #
  def initialize(options = {})
    @timeout    = options[:timeout]            || DEFAULT[:timeout]
    debug       = options[:debug]
    @logger     = (options[:logger]            || (debug ? DebugLogger : DEFAULT[:logger])).new
    attempts    = options[:attempts]           || DEFAULT[:attempts]
    @counter    = (options[:counter]           || DEFAULT[:counter]).new(@logger, attempts)
    delay       = options[:delay]              || DEFAULT[:delay]
    @delayer    = (options[:delayer]           || DEFAULT[:delayer]).new(@logger, delay)
    @tester     = (options[:tester]            || DEFAULT[:tester]).new(@logger)
    exceptions  = Array(options[:rescue])
    @rescuer    = (options[:rescuer]           || DEFAULT[:rescuer]).new(@logger, @tester.exceptions, exceptions)
  end

  # Raised when a block times out.
  class TimeoutError < Timeout::Error; end

  # == Description
  #
  # Wait#until executes a block until there's a valid (by default, truthy)
  # result. Useful for blocking script execution until:
  # * an HTTP request was successful
  # * a port has opened
  # * a process has started
  # * etc.
  #
  # == Examples
  #
  #   wait = Wait.new
  #   # => #<Wait>
  #   wait.until { Time.now.sec.even? }
  #   # [Tester] result: false
  #   # [Rescuer] rescued: Wait::TruthyTester::ResultNotTruthy: false
  #   # [Counter] attempt 1/5 failed
  #   # [Delayer] delaying for 1s
  #   # [Tester] result: true
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
  #   # [Tester] result: nil
  #   # [Rescuer] rescued: Wait::TruthyTester::ResultNotTruthy: nil
  #   # [Counter] attempt 1/5 failed
  #   # [Delayer] delaying for 1s
  #   # [Rescuer] rescued: RuntimeError: RuntimeError
  #   # [Counter] attempt 2/5 failed
  #   # [Delayer] delaying for 1s
  #   # [Tester] result: "foo"
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
      # Increment the attempt counter.
      @counter.increment
      # Wrap the given block in a timeout.
      result = Timeout.timeout(@timeout, TimeoutError) do
        # Execute the block and pass the attempt count (an +Integer+) to it.
        yield(@counter.attempt)
      end
      # Raise an exception unless the result is valid.
      @tester.raise_unless_valid(result)
    rescue *@rescuer.exceptions => exception
      # Raise the exception unless it can be ignored.
      @rescuer.raise_unless_ignore(exception)
      # Raise the exception if this was the last attempt.
      @counter.raise_if_last_attempt(exception)
      # Sleep before the next attempt.
      @delayer.sleep
      # Try the block again.
      retry
    end
  end
end #Wait
