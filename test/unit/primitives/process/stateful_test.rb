require "helper"

class StatefulTest < Test::Unit::TestCase
  context "process" do
    context "when stateful" do
      subject do
        ExampleProcess.create.tap do |process|
          process.send :include, Stampede::Process::Stateful
        end
      end

      context "when setting value" do
        setup do
          @instance = subject.run(DummyRunner.new)
          @instance[:var] = "value"
        end

        should "return previously set variable" do
          assert_equal "value", @instance[:var]
        end

        should "not return previously set variable in other instance" do
          assert_nil subject.run(DummyRunner.new)[:var]
        end
      end
    end
  end
end
