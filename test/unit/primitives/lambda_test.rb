require "helper"

class LambdaTest < Test::Unit::TestCase
  context "lambda" do
    subject do
      @data = data = {}
      Stampede::Lambda.create { data[:flag] = true; finish }
    end

    should "have lambda as name" do
      assert_equal "lambda", subject.process_name
    end

    context "when ran" do
      setup do
        @instance = subject.run
      end

      should "call lambda" do
        assert_equal true, @data[:flag]
      end
    end
  end
end
