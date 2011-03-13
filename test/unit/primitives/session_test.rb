require "helper"

class SessionTest < Test::Unit::TestCase
  context "session" do
    subject { Stampede::Session.create }
    should_behave_like_queue

    should "be named session by default" do
      assert_equal "session", subject.process_name
    end
  end
end
