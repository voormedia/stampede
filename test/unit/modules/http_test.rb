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

    context "when ran standalone" do
      setup do
        runner = DummyRunner.new
        runner.reporter = @reporter = DummyReporter.new
        Timecop.freeze(Time.now)
        EM.run do
          MockServer.start read_fixture("http_responses/google.nl")
          subject.run runner
        end
        @reported = @reporter.reported.first
      end

      teardown { Timecop.return }

      should "report a hash" do
        assert_kind_of Hash, @reported
      end

      should "report http response code" do
        assert_equal 200, @reported[:status]
      end

      should "report latency" do
        assert_equal 0, @reported[:latency]
      end

      should "report content length" do
        assert_equal 9162, @reported[:length]
      end
    end

    context "when ran in session" do
      subject do
        Stampede::Session.create.class_eval do
          use Stampede::Modules::HTTP
          get "http://localhost:99876/"
          self
        end
      end

      setup do
        runner = DummyRunner.new
        runner.reporter = @reporter = DummyReporter.new
        Timecop.freeze(Time.now)
        EM.run do
          MockServer.start read_fixture("http_responses/google.nl")
          @session = subject.run runner
        end
        @reported = @reporter.reported.first
      end

      teardown { Timecop.return }

      should "set cookie in session" do
        assert_equal "PREF=ID=91e9acb4192bc78a:FF=0:TM=1300456190:LM=1300456190:S=fOrXavOfE1_3KuzY",
          @session[:http_cookiejar].get_cookies("http://localhost:99876/").first.to_s
      end

      should "report a hash" do
        assert_kind_of Hash, @reported
      end

      should "report http response code" do
        assert_equal 200, @reported[:actions].first[:status]
      end

      should "report latency" do
        assert_equal 0, @reported[:actions].first[:latency]
      end

      should "report content length" do
        assert_equal 9162, @reported[:actions].first[:length]
      end
    end
  end
end
