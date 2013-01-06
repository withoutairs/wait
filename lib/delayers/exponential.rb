class Wait
  class ExponentialDelayer < RegularDelayer
    def sleep
      super
      increment
    end

    def increment
      @delay *= 2
    end
  end # ExponentialDelayer
end # Wait
