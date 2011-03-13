require "helper"

class ScenarioTest < Test::Unit::TestCase
  context "scenario" do
    subject { Stampede::Scenario.create }
    should_behave_like_group

    context "when loaded from file" do
      subject { Stampede::Scenario.load fixture_path("scenarios/simple.stampede") }

      should "return a subclass of scenario" do
        assert_equal Stampede::Scenario, subject.superclass
      end

      should "append child processes" do
        assert_equal Stampede::Action, subject.children.first.superclass
      end

      should "have file basename as name" do
        assert_equal "simple", subject.process_name
      end
    end
  end
end
