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
        subject.before_finish { report :name => "value" }
        subject.run(@runner)
        assert_equal({:label => "exampleprocess", :name => "value"}, @runner.reporter.reported.first)
      end

      should "report name and nil value" do
        subject.before_finish { report :name => nil }
        subject.run(@runner)
        assert_nil @runner.reporter.reported.first[:name]
      end

      context "from child" do
        setup do
          @context = ExampleProcess.create.send(:new, @runner)
        end

        should "send data to through context to reporter" do
          subject.before_finish { report :name => "value" }
          subject.run(@context)
          assert_equal({:label => "exampleprocess", :name => "value"}, @runner.reporter.reported.first)
        end
      end
    end
  end
end
