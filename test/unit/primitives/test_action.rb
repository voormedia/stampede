require "helper"

class TimedExampleAction < Stampede::Action
  def start
    Timecop.freeze(Time.now + 10)
    finish
  end
end

class TestAction < Test::Unit::TestCase
  context "action" do
    subject { TimedExampleAction.new }

    context "when ran" do
      setup do
        Timecop.freeze(@start = Time.now)
        @running = subject.run
      end
      
      teardown { Timecop.return }

      should "record start time" do
        assert_equal @start, @running.send(:start_time)
      end

      should "record stop time" do
        assert_equal @start + 10, @running.send(:stop_time)
      end

      should "be timed" do
        assert_equal 10 * 1000, @running.send(:elapsed)
      end
    end
  end
end
