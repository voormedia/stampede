require "helper"

class TestScenario < Test::Unit::TestCase
  context "scenario" do
    subject { Stampede::Scenario.new }
    should_behave_like_group

    context "when loaded from file" do
      subject { Stampede::Scenario.load fixture_path("scenarios/simple.stampede") }

      should "return a scenario" do
        assert_kind_of Stampede::Scenario, subject
      end

      should "append child processes" do
        assert_kind_of Stampede::Process, subject.children.first
      end

      should "have file basename as name" do
        assert_equal "simple", subject.name
      end
    end
  end
end
