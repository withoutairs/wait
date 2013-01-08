class Wait
  class TruthyTester < BaseTester
    def valid?
      not (@result.nil? or @result == false)
    end
  end # TruthyTester
end # Wait
