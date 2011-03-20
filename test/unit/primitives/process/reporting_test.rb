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

      context "name and value" do
        setup do
          subject.before_finish { report :name => "value" }
          subject.run(@runner)
        end

        should "include reported value" do
          assert_equal "value", @runner.reporter.reported.first[:name]
        end

        should "include process name" do
          assert_equal "exampleprocess", @runner.reporter.reported.first[:label]
        end
      end

      context "name and nil value" do
        setup do
          subject.before_finish { report :name => nil }
          subject.run(@runner)
        end

        should "include reported nil value" do
          assert_nil @runner.reporter.reported.first[:name]
        end
      end

      context "from child" do
        setup do
          @context = ExampleProcess.create.send(:new, @runner)
        end

        should "send data to through context to reporter" do
          subject.before_finish { report :name => "value" }
          subject.run(@context)
          assert_equal "value", @runner.reporter.reported.first[:name]
        end
      end
    end
  end
end
