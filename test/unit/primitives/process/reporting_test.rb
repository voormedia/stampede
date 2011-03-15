require "helper"

class ReportingTest < Test::Unit::TestCase
  context "process" do
    subject do
      ExampleProcess.create.tap do |process|
        process.send :include, Stampede::Process::Reporting
      end
    end

    context "when reporting" do
      setup do
        @runner = DummyRunner.new
        @runner.reporter = DummyReporter.new
      end

      should "report name and value" do
        subject.before_finish { report :name => "value"; send_report }
        subject.run(@runner)
        assert_equal "value", @runner.reporter.reported.first["exampleprocess"][:name]
      end

      should "report name and nil value" do
        subject.before_finish { report :name => nil }
        subject.run(@runner)
        assert_nil @runner.reporter.reported.first["exampleprocess"][:name]
      end
    end
  end
end
