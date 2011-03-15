require "helper"

class HTTPTest < Test::Unit::TestCase
  context "process" do
    subject { ExampleProcess.create }

    context "with http" do
      setup { subject.use Stampede::Modules::HTTP }

      should_respond_to :get, :post, :put, :delete, :head
    end
  end

  context "request" do
    subject do
      Stampede::Scenario.create.class_eval do
        use Stampede::Modules::HTTP
        get "http://example.com"
        self
      end
    end

    context "when ran" do
      setup do
        stub_request(:get, "http://example.com").to_return({ :status => 200, :body => "abc" }, { :body => "def" })
        runner = DummyRunner.new
        runner.reporter = @reporter = DummyReporter.new
        EM.run { subject.run runner }
      end

      should "report http response code" do
        assert_equal 200, @reporter.reported.first[1][:status]
      end
    end
  end
end
