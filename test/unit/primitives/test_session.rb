require "helper"

class TestSession < Test::Unit::TestCase
  context "session" do
    subject { Stampede::Session.new }
    should_behave_like_queue
    
    should "be named session by default" do
      assert_equal "session", subject.name
    end
  end
end
