require "helper"

class DummyRunner
  def initialize(reporter)
    @reporter = reporter
  end

  def report(*args)
    @reporter.report(*args)
  end

  def finish; end
end

class ReportingTest < Test::Unit::TestCase
  context "process" do
    subject { ExampleProcess.create }

    setup do
      $stdout = @stdout = StringIO.new
      @reporter = Stampede::Reporters::Console.new
    end

    teardown do
      $stdout = STDOUT
    end

    context "when reporting" do
      setup do
        @instance = subject.run(DummyRunner.new(@reporter))
      end

      should "report name and value" do
        @instance.report("name", "value")
        assert_equal "exampleprocess.name: value\n", @stdout.string
      end

      should "report name and nil value" do
        @instance.report("name")
        assert_equal "exampleprocess.name: \n", @stdout.string
      end
    end
  end
end
