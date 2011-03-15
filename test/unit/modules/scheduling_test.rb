require "helper"

class SchedulingTest < Test::Unit::TestCase
  context "process" do
    subject { ExampleProcess.create }

    context "with scheduling" do
      setup { subject.use Stampede::Modules::Scheduling }

      should_respond_to :every
    end
  end

  context "number" do
    subject { 10.ms }

    should "be convertable to milliseconds" do
      assert_equal 1, subject * 100
    end
  end

  context "interval" do
    subject do
      Stampede::Scenario.create.class_eval do
        use Stampede::Modules::Scheduling
        every 0 do
          action do
            report :time => Time.now
            finish
          end
        end
        self
      end
    end

    context "when ran" do
      setup do
        runner = DummyRunner.new
        runner.reporter = @reporter = DummyReporter.new
        Timecop.freeze(Time.now)
        EM.run do
          EM.set_quantum(5)
          subject.run runner
          EM.next_tick { EM.next_tick { EM.next_tick { EM.stop } } }
        end
      end

      teardown { Timecop.return }

      should "start children every interval" do
        assert_equal 3, @reporter.reported.length
      end
    end
  end
end
