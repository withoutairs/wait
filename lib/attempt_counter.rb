class Wait
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
end # Wait
