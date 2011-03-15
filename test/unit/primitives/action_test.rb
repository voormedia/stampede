require "helper"

class TimedExampleAction < Stampede::Action
  class_attribute :delay

  class << self
    def initialize(delay = 10)
      self.delay = delay
      super
    end
  end

  def start
    Timecop.freeze(Time.now + delay)
    finish
  end
end

class ActionTest < Test::Unit::TestCase
  context "action" do
    subject { TimedExampleAction.create }

    context "when ran" do
      setup do
        Timecop.freeze(@start = Time.now)
        @instance = subject.run DummyRunner.new
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

    context "when timing out" do
      subject { TimedExampleAction.create }

      setup do
        Timecop.freeze(@start = Time.new)
        subject.after_start
        @instance = subject.run DummyRunner.new
      end

      teardown { Timecop.return }

      should "be killed" do
      end
    end
  end
end
