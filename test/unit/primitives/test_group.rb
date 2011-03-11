require "helper"

class TestGroup < Test::Unit::TestCase
  context "group" do
    subject { Stampede::Group.new }
    should_behave_like_group
  end
end
