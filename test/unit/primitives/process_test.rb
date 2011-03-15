require "helper"

class ProcessTest < Test::Unit::TestCase
  context "process class" do
    subject { Stampede::Process }

    context "when inspected" do
      should "show name" do
        assert_equal "Stampede::Process", subject.inspect
      end
    end
  end

  context "process" do
    subject { ExampleProcess.create }

    should "be named after class" do
      assert_equal "exampleprocess", subject.process_name
    end

    should_not_respond_to :new

    context "when ran" do
      setup do
        subject.before_start :flag
        @runner = DummyRunner.new
        @context = ExampleProcess.create.send(:new, @runner)
        @instance = subject.run(@context)
      end

      should "be instantiated" do
        assert_kind_of subject, @instance
      end

      should "invoke start on instance" do
        assert @instance.flagged?
      end

      should "contain reference to context" do
        assert_equal @context, @instance.context
      end

      should "contain reference to runner" do
        assert_equal @runner, @instance.runner
      end
    end

    context "when finished" do
      setup do
        subject.run @context = ExampleProcess.create.send(:new, DummyRunner.new)
      end

      should "call finish on context" do
        assert @context.finished?
      end
    end

    context "when finish is spuriously called" do
      setup do
        subject.after_start { finish; finish }
      end

      should "raise" do
        assert_raises Stampede::Process::FinishedError do
          subject.run DummyRunner.new
        end
      end
    end

    context "when inspected" do
      subject { Stampede::Process.create }

      should "show superclass name" do
        assert_equal "subclass of Stampede::Process", subject.inspect
      end
    end
  end

  context "bare process" do
    subject { Stampede::Process.create }

    should "raise not implemented error when ran" do
      assert_raises NotImplementedError do
        subject.run DummyRunner.new
      end
    end
  end
end
