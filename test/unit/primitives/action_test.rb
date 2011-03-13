require "helper"

class TimedExampleAction < Stampede::Action
  def start
    Timecop.freeze(Time.now + 10)
    finish
  end
end

class ActionTest < Test::Unit::TestCase
  context "action" do
    subject { TimedExampleAction.create }

    context "when ran" do
      setup do
        Timecop.freeze(@start = Time.now)
        @instance = subject.run
      end

      teardown { Timecop.return }

      should "record start time" do
        assert_equal @start, @instance.send(:start_time)
      end

      should "record stop time" do
        assert_equal @start + 10, @instance.send(:stop_time)
      end

      should "be timed" do
        assert_equal 10 * 1000, @instance.send(:elapsed)
      end
    end
  end
end
