require "helper"

class TestSession < Test::Unit::TestCase
  context "session" do
    subject { Stampede::Session.new }
    should_behave_like_queue
  end
end
