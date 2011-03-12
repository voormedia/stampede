require "helper"

class TestCallbacks < Test::Unit::TestCase
  context "process" do
    setup { @klass = Class.new ExampleProcess }
    subject { @klass.new }

    context "with callbacks" do
      should "call before_start" do
        @klass.class_eval { before_start :flag }
        subject.send(:dispatch)
        assert subject.flagged?
      end

      should "call after_start" do
        @klass.class_eval { after_start :flag }
        subject.send(:dispatch)
        assert subject.flagged?
      end

      should "call before_stop" do
        @klass.class_eval { before_finish :flag }
        subject.send(:finish)
        assert subject.flagged?
      end

      should "call after_stop" do
        @klass.class_eval { after_finish :flag }
        subject.send(:finish)
        assert subject.flagged?
      end
    end

    context "with callbacks from superclass" do
      setup do
        @descendant_klass = Class.new(Class.new(@klass))
        @descendant = @descendant_klass.new
      end

      should "call callback once" do
        called = 0
        @klass.class_eval { before_start { called += 1 } }
        @descendant.send(:dispatch)
        assert_equal 1, called
      end
    end
  end
end
