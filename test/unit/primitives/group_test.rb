require "helper"

class GroupTest < Test::Unit::TestCase
  context "group" do
    subject { Stampede::Group.create }
    should_behave_like_group
  end
end
