require "helper"

class ConsoleTest < Test::Unit::TestCase
  context "console reporter" do
    subject { Stampede::Reporters::Console.new }

    setup do
      $stdout = @stdout = StringIO.new
    end

    teardown do
      $stdout = STDOUT
    end

    context "when reported to" do
      setup do
        subject.report "name", "value"
      end

      should "output to stdout" do
        assert_equal "name: value\n", @stdout.string
      end
    end
  end
end
