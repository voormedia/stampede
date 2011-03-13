require "helper"

class TestActions < Test::Unit::TestCase
  context "scenario" do
    subject { Stampede::Scenario.new }

    should_respond_to :action, :session, :wait, :define

    context "with action" do
      setup do
        subject.action { finish }
      end

      should "have action as child" do
        assert_kind_of Stampede::Lambda, subject.children.first
      end

      context "when ran" do
        setup { @running = subject.run }

        should "execute action" do
          assert_equal true, @running.finished?
        end
      end
    end

    context "with named action" do
      setup do
        subject.action("awesome action") { finish }
      end

      should "have child action with given name" do
        assert_equal "awesome action", subject.children.first.name
      end
    end

    context "with session" do
      setup do
        subject.session { action { finish } }
      end

      should "have session as child" do
        assert_kind_of Stampede::Session, subject.children.first
      end

      should "append child actions to session" do
        assert_kind_of Stampede::Lambda, subject.children.first.children.first
      end

      context "when ran" do
        setup { @running = subject.run }

        should "execute session" do
          assert_equal true, @running.finished?
        end
      end
    end

    context "with wait action" do
      setup do
        subject.wait 0.001
      end

      should "have wait action as child" do
        assert_equal "wait", subject.children.first.name
      end
    end

    context "with define block" do
      setup do
        subject.define do
          def foo
            action("foo") { finish }
          end
        end
      end

      should "include methods in block" do
        assert_equal [:foo], subject.extensions.last.instance_methods
      end

      should "append action defined by extension method" do
        subject.foo
        assert_equal "foo", subject.children.last.name
      end
    end
  end
end
