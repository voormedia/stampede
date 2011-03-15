require "helper"

class ActionsTest < Test::Unit::TestCase
  context "scenario" do
    subject { Stampede::Scenario.create }

    should_respond_to :create, :action, :session, :wait

    context "with process" do
      setup do
        subject.create Stampede::Lambda, proc { finish }
      end

      should "have action as child" do
        assert_equal Stampede::Lambda, subject.children.first.superclass
      end

      context "when ran" do
        setup { @instance = subject.run(DummyRunner.new) }

        should "execute action" do
          assert_equal true, @instance.finished?
        end
      end
    end

    context "with action" do
      setup do
        subject.action { finish }
      end

      should "have action as child" do
        assert_equal Stampede::Lambda, subject.children.first.superclass
      end

      context "when ran" do
        setup { @instance = subject.run(DummyRunner.new) }

        should "execute action" do
          assert_equal true, @instance.finished?
        end
      end
    end

    context "with named action" do
      setup do
        subject.action("awesome action") { finish }
      end

      should "have child action with given name" do
        assert_equal "awesome action", subject.children.first.process_name
      end
    end

    context "with session" do
      setup do
        subject.session { action { finish } }
      end

      should "have session as child" do
        assert_equal Stampede::Session, subject.children.first.superclass
      end

      should "append child actions to session" do
        assert_equal Stampede::Lambda, subject.children.first.children.first.superclass
      end

      context "when ran" do
        setup { @instance = subject.run(DummyRunner.new) }

        should "execute session" do
          assert_equal true, @instance.finished?
        end
      end
    end

    context "with wait action" do
      setup do
        subject.wait 0.001
      end

      should "have wait action as child" do
        assert_equal "wait 0.001", subject.children.first.process_name
      end
    end
  end
end
