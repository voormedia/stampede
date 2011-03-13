require "helper"

module AwesomeModule
  def awesome_method; end
end

class ExtendingTest < Test::Unit::TestCase
  context "process" do
    subject { ExampleProcess.create }

    context "when extended" do
      setup { subject.use AwesomeModule }

      should "respond to new methods" do
        assert_respond_to subject, :awesome_method
      end
    end

    context "when augmented" do
      context "with extended process" do
        setup do
          subject.use AwesomeModule
          @derived = subject.augment(Stampede::Process.create)
        end

        should "return subclass of given class" do
          assert_equal Stampede::Process, @derived.superclass
        end

        should "respond to new methods" do
          assert_respond_to @derived, :awesome_method
        end
      end

      context "with bare process" do
        setup do
          @derived = subject.augment(Stampede::Process.create)
        end

        should "return subclass of given class" do
          assert_equal Stampede::Process, @derived.superclass
        end
      end
    end

    context "when augmented with block" do
      context "with extended process" do
        setup { subject.use AwesomeModule }

        should "extend before yielding" do
          respond = nil
          subject.augment(Stampede::Process.create) { respond = respond_to?(:awesome_method) }
          assert_equal true, respond
        end
      end
    end
  end
end
