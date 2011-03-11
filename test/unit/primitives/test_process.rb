require "helper"

class TestProcess < Test::Unit::TestCase
  context "process" do
    setup do
      @klass = Class.new ExampleProcess
      @object = @klass.new
    end

    subject { @object }

    context "callback" do
      should "be created by before_start" do
        @klass.class_eval { before_start :flag }
        @object.send(:dispatch)
        assert @object.flagged?
      end

      should "be created by after_start" do
        @klass.class_eval { after_start :flag }
        @object.send(:dispatch)
        assert @object.flagged?
      end

      should "be created by before_stop" do
        @klass.class_eval { before_finish :flag }
        @object.send(:finish)
        assert @object.flagged?
      end

      should "be created by after_stop" do
        @klass.class_eval { after_finish :flag }
        @object.send(:finish)
        assert @object.flagged?
      end
    end

    context "when ran" do
      setup do
        @klass.class_eval { before_start :flag }
        @running = @object.run
      end

      should "be duped" do
        assert !@object.flagged?
      end

      should "invoke start on dupe" do
        assert @running.flagged?
      end

      should "return process" do
        assert_kind_of Stampede::Process, @running
      end

      should "return dupe" do
        assert_not_equal @object.object_id, @running.object_id
      end

      # should "not change state" do
      #   object = ExampleProcess.new
      #   copy = object.dup
      #   object.run
      #   assert_equal Marshal.dump(copy), Marshal.dump(object)
      # end
      #
      # should "change state of duped object" do
      #   object = ExampleProcess.new
      #   copy = object.dup
      #   object.dispatch
      #   assert_not_equal Marshal.dump(copy), Marshal.dump(object)
      # end

      should "be marked as copy" do
        assert_equal true, @running.copy?
      end
    end

    context "when inspected" do
      subject { Stampede::Process.new.inspect }

      should "include copy and finished status" do
        assert_match /Stampede::Process:0x[a-f\d]+ @copy=false @finished=false/, subject
      end
    end
  end

  context "bare process" do
    subject { Stampede::Process.new }

    should "raise not implemented error when ran" do
      assert_raises NotImplementedError do
        subject.run
      end
    end
  end
end
