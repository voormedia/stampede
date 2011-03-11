require "helper"

module AwesomeModule
  def awesome_method; end
end

class TestProcess < Test::Unit::TestCase
  context "process" do
    subject { ExampleProcess.new }

    context "when extended" do
      setup { subject.use AwesomeModule }

      should "respond to new methods" do
        assert subject.respond_to?(:awesome_method)
      end
    end

    context "when derived" do
      context "from extended process" do
        setup do
          subject.use AwesomeModule
          @derived = subject.derive(Stampede::Process)
        end

        should "return instance of given class" do
          assert_kind_of Stampede::Process, @derived
        end

        should "respond to new methods" do
          assert @derived.respond_to?(:awesome_method)
        end
      end

      context "from bare process" do
        setup do
          @derived = subject.derive(Stampede::Process)
        end

        should "return instance of given class" do
          assert_kind_of Stampede::Process, @derived
        end
      end
    end

    context "when derived with block" do
      context "from extended process" do
        setup { subject.use AwesomeModule }

        should "extend before yielding" do
          respond = nil
          subject.derive(Stampede::Process) { respond = respond_to?(:awesome_method) }
          assert_equal true, respond
        end
      end
    end
  end
end
