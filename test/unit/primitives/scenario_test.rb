require "helper"

class ScenarioTest < Test::Unit::TestCase
  context "scenario" do
    subject { Stampede::Scenario.create }
    should_behave_like_group

    context "when created from file" do
      subject { Stampede::Scenario.from_file fixture_path("scenarios/simple.stampede") }

      should "return a subclass of scenario" do
        assert_equal Stampede::Scenario, subject.superclass
      end

      should "append child processes" do
        assert_equal ExampleProcess, subject.children.first.superclass
      end

      should "have file basename as name" do
        assert_equal "simple", subject.process_name
      end
    end

    should_respond_to :load

    context "when loading file" do
      setup do
        3.times { subject.load fixture_path("scenarios/simple.stampede") }
      end

      should "append contents to scenario" do
        assert_equal [ExampleProcess] * 3, subject.children.map(&:superclass)
      end
    end
  end
end
