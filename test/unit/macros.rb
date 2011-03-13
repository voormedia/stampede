require "eventmachine"

class Test::Unit::TestCase
  def self.should_behave_like_collection
    context "without children" do
      context "when ran" do
        setup { @instance = subject.run }

        should "finish" do
          assert_equal true, @instance.finished?
        end
      end
    end

    context "with children" do
      setup do
        klass = ExampleProcess.create
        klass.class_eval do
          before_start do
            @context.instance_variable_set(:@_num, (@context.instance_variable_get(:@_num) || 0) + 1)
          end
        end
        3.times { subject.push(klass) }
      end

      context "when ran" do
        setup { @instance = subject.run }

        should "finish" do
          assert_equal true, @instance.finished?
        end

        should "run children" do
          assert_equal 3, @instance.instance_variable_get(:@_num)
        end
      end
    end

    context "when appending children" do
      setup do
        @children = []
        3.times do
          @children << (child = ExampleProcess.create)
          subject.push(child)
        end
      end

      should "save children" do
        assert_equal @children, subject.children
      end
    end
  end

  def self.should_behave_like_queue
    should_behave_like_collection

    context "with asynchronous actions" do
      setup do
        @children = children = []
        push_async_child(subject, 0.002, 1, 3)
        push_async_child(subject, 0.001, 2, 3)
        push_async_child(subject, 0.000, 3, 3)
      end

      context "when ran" do
        setup do
          EventMachine.run { EventMachine.set_quantum(5); subject.run }
        end

        should "execute children in order" do
          assert_equal [1, 2, 3], @children
        end
      end
    end
  end

  def self.should_behave_like_group
    should_behave_like_collection

    context "with asynchronous actions" do
      setup do
        @children = []
        push_async_child(subject, 0.002, 1, 3)
        push_async_child(subject, 0.001, 2, 3)
        push_async_child(subject, 0.000, 3, 3)
      end

      context "when ran" do
        setup do
          EventMachine.run { EventMachine.set_quantum(5); subject.run }
        end

        should "execute children in parallel" do
          assert_equal [3, 2, 1], @children
        end
      end
    end
  end

  def self.should_respond_to(*methods)
    methods.each do |method|
      should "respond to #{method}" do
        assert_respond_to subject, method
      end
    end
  end

  def self.should_not_respond_to(*methods)
    methods.each do |method|
      should "not respond to #{method}" do
        assert !subject.respond_to?(method)
      end
    end
  end

  private

  def push_async_child(subject, timer, num, total)
    children = @children
    subject.push Stampede::Lambda.create {
      EventMachine.add_timer(timer) do
        children << num
        EventMachine.stop if children.length == total
        finish
      end
    }
  end
end
