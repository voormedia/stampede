require "helper"

class TestHTTP < Test::Unit::TestCase
  context "process" do
    setup { @klass = Class.new ExampleProcess }
    subject { @klass.new }

    context "with http" do
      setup { subject.use Stampede::Modules::HTTP }
      
      should_respond_to :get, :post, :put, :delete, :head
    end
  end
end
