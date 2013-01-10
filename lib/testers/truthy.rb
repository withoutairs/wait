class Wait
  class TruthyTester < BaseTester
    def valid?(result)
      log(result)

      not (result.nil? or result == false)
    end
  end # TruthyTester
end # Wait
