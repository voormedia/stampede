require "helper"

class CallbacksTest < Test::Unit::TestCase
  context "process" do
    subject { ExampleProcess.create }

    context "with callbacks" do
      should "call before_start" do
        subject.class_eval { before_start :flag }
        assert subject.run.flagged?
      end

      should "call after_start" do
        subject.class_eval { after_start :flag }
        assert subject.run.flagged?
      end

      should "call before_stop" do
        subject.class_eval { before_finish :flag }
        assert subject.run.flagged?
      end

      should "call after_stop" do
        subject.class_eval { after_finish :flag }
        assert subject.run.flagged?
      end
    end

    context "with callbacks from superclass" do
      setup { @super = ExampleProcess.create }
      subject { @super.create.create.create }

      should "call callback once" do
        called = 0
        @super.class_eval { before_start { called += 1 } }
        subject.run
        assert_equal 1, called
      end
    end
  end
end
