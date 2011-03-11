require "helper"

class TestQueue < Test::Unit::TestCase
  context "queue" do
    subject { Stampede::Queue.new }
    should_behave_like_queue
  end
end
