require "helper"

class ReportingTest < Test::Unit::TestCase
  context "process" do
    context "when verbosity" do
      subject do
        ExampleProcess.create.tap do |process|
          process.send :include, Stampede::Process::Verbose
        end
      end

      setup do
        @out = StringIO.new
        class << @out
          alias_method :write_nonblock, :write
        end
        @runner = DummyRunner.new
        @runner.logger = Stampede::Logger.new(@out)
        subject.run(@runner)
        @runner.logger.flush
      end

      should "report start" do
        assert_match />> Starting exampleprocess/, @out.string
      end

      should "report finish" do
        assert_match /<< Finished exampleprocess/, @out.string
      end
    end
  end
end
