require "helper"

class HTTPTest < Test::Unit::TestCase
  context "process" do
    subject { ExampleProcess.create }

    context "with http" do
      setup { subject.use Stampede::Modules::HTTP }

      should_respond_to :get, :post, :put, :delete, :head
    end
  end
end
