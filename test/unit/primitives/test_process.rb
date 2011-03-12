require "helper"

class TestProcess < Test::Unit::TestCase
  context "process" do
    setup do
      @klass = Class.new ExampleProcess
      @object = @klass.new
    end

    subject { @object }

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
