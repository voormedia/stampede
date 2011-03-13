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
        subject.class_eval { before_start :flag }
        @instance = subject.run
      end

      should "be instantiated" do
        assert_kind_of subject, @instance
      end

      should "invoke start on instance" do
        assert @instance.flagged?
      end
    end

    context "when inspected" do
      subject { Stampede::Process.create }

      should "show superclass name" do
        assert_equal "#<Class:Stampede::Process>", subject.inspect
      end
    end
  end

  context "bare process" do
    subject { Stampede::Process.create }

    should "raise not implemented error when ran" do
      assert_raises NotImplementedError do
        subject.run
      end
    end
  end
end
