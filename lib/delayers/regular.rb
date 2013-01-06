class Wait
  class RegularDelayer
    def initialize(initial_delay)
      @delay = initial_delay
    end

    def sleep
      Kernel.sleep(@delay)
    end

    def to_s
      "#{@delay}s"
    end
  end # RegularDelayer
end # Wait
