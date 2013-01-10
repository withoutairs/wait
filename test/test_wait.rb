require "test/unit"
require "wait"

class WaitTest < Test::Unit::TestCase
  # An exception used for testing (1/2).
  class TestErrorFoo < StandardError; end

  # An exception used for testing (2/2).
  class TestErrorBar < StandardError; end

  # A very short delay useful for testing.
  DELAY = 0.001

  # Test that the result of the block is the result of Wait#until.
  def test_result
    options = {:delay => DELAY, :attempts => 1}
    wait = Wait.new(options)
    result = wait.until { "foo" }
    assert_equal "foo", result
  end

  # Test that Wait::ResultInvalid is raised when the last attempt returns a
  # non-truthy result.
  def test_raising_non_truthy_result
    options = {:delay => DELAY, :attempts => 1}
    wait = Wait.new(options)
    assert_raise Wait::ResultInvalid do
      wait.until { nil }
    end
  end

  # Test that Wait::TimeoutError is raised when the last attempt times out.
  def test_raising_timeout
    options = {:delay => DELAY, :attempts => 1, :timeout => 1}
    wait = Wait.new(options)
    assert_raise Wait::TimeoutError do
      wait.until { sleep }
    end
  end

  # Test that WaitTest::TestErrorFoo is raised when the last attempt raises
  # WaitTest::TestErrorFoo.
  def test_raising_other
    options = {:delay => DELAY, :attempts => 1, :rescue => WaitTest::TestErrorFoo}
    wait = Wait.new(options)
    assert_raise WaitTest::TestErrorFoo do
      wait.until { raise WaitTest::TestErrorFoo }
    end
  end

  # Test that delays are inserted between each attempt and that they do not
  # grow.
  def test_regular_delayer
    # Set up the initial delay value and strategy to use.
    delay = 0.1
    delayer = Wait::RegularDelayer.new(delay)
    attempts = 4
    options = {:delayer => delayer, :attempts => attempts}
    wait = Wait.new(options)

    # Initialize a variable to store timing information.
    t = Array.new(attempts + 1)
    t[0] = Time.now

    result = wait.until do |attempt|
      t[attempt] = Time.now
      # Return false to raise Wait::NoResultError and move on to the next
      # attempt.
      attempt == 4
    end

    assert_equal 0,     ((t[1] - t[0]) * 10).round / 10.0
    assert_equal delay, ((t[2] - t[1]) * 10).round / 10.0
    assert_equal delay, ((t[3] - t[2]) * 10).round / 10.0
    assert_equal delay, ((t[4] - t[3]) * 10).round / 10.0
  end

  # Test that delays are inserted between each attempt and that they grow
  # exponentially.
  def test_exponential_delayer
    # Set up the initial delay value and strategy to use.
    delay = 0.1
    delayer = Wait::ExponentialDelayer.new(delay)
    attempts = 4
    options = {:delayer => delayer, :attempts => attempts}
    wait = Wait.new(options)

    # Initialize a variable to store timing information.
    t = Array.new(attempts + 1)
    t[0] = Time.now

    result = wait.until do |attempt|
      t[attempt] = Time.now
      # Return false to raise Wait::NoResultError and move on to the next
      # attempt.
      attempt == 4
    end

    assert_equal 0,          ((t[1] - t[0]) * 10).round / 10.0
    assert_equal delay,      ((t[2] - t[1]) * 10).round / 10.0
    assert_equal delay *= 2, ((t[3] - t[2]) * 10).round / 10.0
    assert_equal delay *= 2, ((t[4] - t[3]) * 10).round / 10.0
  end

  # Test that a +nil+ result is rescued.
  def test_rescuing_nil_result
    options = {:delay => DELAY, :attempts => 2}
    wait = Wait.new(options)
    result = wait.until do |attempt|
      case attempt
      when 1 then nil
      when 2 then "foo"
      end
    end
    assert_equal "foo", result
  end

  # Test that a +false+ result is rescued.
  def test_rescuing_false_result
    options = {:delay => DELAY, :attempts => 2}
    wait = Wait.new(options)
    result = wait.until do |attempt|
      case attempt
      when 1 then false
      when 2 then "foo"
      end
    end
    assert_equal "foo", result
  end

  # Test that a timeout is rescued.
  def test_rescuing_timeout
    options = {:delay => DELAY, :attempts => 2, :timeout => 1}
    wait = Wait.new(options)
    result = wait.until do |attempt|
      case attempt
      when 1 then sleep
      when 2 then "foo"
      end
    end
    assert_equal "foo", result
  end

  # Test that an exception specified by the +:rescue+ option
  # (WaitTest::TestErrorFoo) is rescued.
  def test_rescuing_exception_specified_by_rescue_option
    options = {:delay => DELAY, :attempts => 2, :rescue => WaitTest::TestErrorFoo}
    wait = Wait.new(options)
    result = wait.until do |attempt|
      case attempt
      when 1 then raise WaitTest::TestErrorFoo
      when 2 then "foo"
      end
    end
    assert_equal "foo", result
  end

  # Test that an exception *not* specified by the +:rescue+ option
  # (WaitTest::TestErrorBar) is *not* rescued.
  def test_not_rescuing_exception_not_specified_by_rescue_option
    options = {:delay => DELAY, :attempts => 2, :rescue => WaitTest::TestErrorFoo}
    wait = Wait.new(options)
    assert_raise WaitTest::TestErrorBar do
      wait.until do |attempt|
        case attempt
        when 1 then raise WaitTest::TestErrorBar
        when 2 then "foo"
        end
      end
    end
  end

  # Test a few combinations of invalid number of attempts. Validation is
  # performed here to prevent accidentally causing an infinite loop.
  def test_invalid_number_of_attempts
    assert_raise ArgumentError do
      Wait.new(:attempts => 0).until { }
    end

    assert_raise ArgumentError do
      Wait.new(:attempts => 1.1).until { }
    end

    assert_raise ArgumentError do
      Wait.new(:attempts => 1.1).until { }
    end
  end
end
