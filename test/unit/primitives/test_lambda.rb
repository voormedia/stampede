require "helper"

class TestLambda < Test::Unit::TestCase
  context "lambda" do
    subject do
      @data = data = {}
      Stampede::Lambda.new { data[:flag] = true; finish }
    end

    context "when ran" do
      setup do
        @running = subject.run
      end

      should "call lambda" do
        assert_equal true, @data[:flag]
      end
    end
  end
end
