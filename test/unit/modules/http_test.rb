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
        get "http://localhost:99876/"
        self
      end
    end

    context "when ran" do
      setup do
        runner = DummyRunner.new
        runner.reporter = @reporter = DummyReporter.new
        EM.run do
          MockServer.start read_fixture("http_responses/google.nl")
          subject.run runner
        end
      end

      should "report http response code" do
        assert_equal 200, @reporter.reported.first[:status]
      end
    end
  end
end
