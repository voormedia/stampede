require "helper"

class QueueTest < Test::Unit::TestCase
  context "queue" do
    subject { Stampede::Queue.create }
    should_behave_like_queue
  end
end
