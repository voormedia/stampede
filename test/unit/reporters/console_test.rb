require "helper"

class ConsoleTest < Test::Unit::TestCase
  context "console reporter" do
    subject { Stampede::Reporters::Console.new(@logger = Stampede::Logger.new(@stdout = StringIO.new)) }

    context "when reported to" do
      setup do
        subject.report "name", :variable => "value"
        @logger.flush
      end

      should "output to stdout" do
        assert_equal "Report for 'name':\n\n          variable: \"value\"\n\n", @stdout.string
      end
    end
  end
end
