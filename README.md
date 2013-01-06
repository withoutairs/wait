[![Build Status](https://travis-ci.org/paperlesspost/wait.png?branch=master)](https://travis-ci.org/paperlesspost/wait)

## Description

The wait gem executes a block until there's a valid (by default, truthy) result. Useful for blocking script execution until:
* an HTTP request was successful
* a port has opened
* a process has started
* etc.

## Installation

Add to your `Gemfile`:

```ruby
gem "wait", "~> 0.3"
```

## Examples

```ruby
wait = Wait.new
# => #<Wait>
wait.until { Time.now.sec.even? }
# [Tester] result: false
# [Rescuer] rescued: Wait::TruthyTester::ResultNotTruthy: false
# [Counter] attempt 1/5 failed
# [Delayer] delaying for 1s
# [Tester] result: true
# => true
```

If you wish to handle an exception by attempting the block again, pass one or an array of exceptions with the `:rescue` option.

```ruby
wait = Wait.new(:rescue => RuntimeError)
# => #<Wait>
wait.until do |attempt|
  case attempt
  when 1 then nil
  when 2 then raise RuntimeError
  when 3 then "foo"
  end
end
# [Tester] result: nil
# [Rescuer] rescued: Wait::TruthyTester::ResultNotTruthy: nil
# [Counter] attempt 1/5 failed
# [Delayer] delaying for 1s
# [Rescuer] rescued: RuntimeError: RuntimeError
# [Counter] attempt 2/5 failed
# [Delayer] delaying for 1s
# [Tester] result: "foo"
# => "foo"
```

## Options

<dl>
<dt>attempts</dt>
<dd>Number of times to attempt the block (passed to <code>counter</code>). Default is <code>5</code>.</dd>
<dt>counter</dt>
<dd>Strategy used to count attempts. Default is <code>Wait::BaseCounter</code>.</dd>
<dt>timeout</dt>
<dd>Seconds until the block times out. Default is <code>15</code>.</dd>
<dt>delay</dt>
<dd>Seconds to delay in between attempts (passed to <code>delayer</code>). Default is <code>1</code>.</dd>
<dt>delayer</dt>
<dd>Strategy used to delay in between attempts. Default is <code>Wait::RegularDelayer</code>.</dd>
<dt>rescue</dt>
<dd>One or an array of exceptions to rescue (passed to <code>rescuer</code>). Default is <code>nil</code>.</dd>
<dt>rescuer</dt>
<dd>Strategy used to handle exceptions. Default is <code>Wait::PassiveRescuer</code>.</dd>
<dt>tester</dt>
<dd>Strategy used to test the result. Default is <code>Wait::TruthyTester</code>.</dd>
<dt>logger</dt>
<dd>Ruby logger used. Default is <code>Wait::BaseLogger</code>.</dd>
</dl>

## Documentation

RDoc-generated documentation available [here](http://paperlesspost.github.com/wait/).
