require "helper"

class HTTPTest < Test::Unit::TestCase
  def setup_response(name)
    EM.run do
      MockServer.start read_fixture("http_responses/#{name}")
      @instance = subject.run @runner
    end
    @reported = @reporter.reported.first
  end

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

    setup do
      Timecop.freeze(Time.now)
      @runner = DummyRunner.new
      @runner.reporter = @reporter = DummyReporter.new
    end

    teardown { Timecop.return }

    context "when ran standalone" do
      setup do
        setup_response "google.nl"
      end

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

      should "report correct label" do
        assert_equal "get http://localhost:99876/", @reported[:label]
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

      context "with multiple cookies" do
        setup do
          setup_response "google.nl"
        end

        should "set first cookie in session" do
          assert_equal "PREF=ID=91e9acb4192bc78a:FF=0:TM=1300456190:LM=1300456190:S=fOrXavOfE1_3KuzY",
            @instance[:http_cookiejar].get_cookies("http://localhost:99876/")[0].to_s
        end

        should "set second cookie in session" do
          assert_equal "NID=45=AHVUp1ZHBPCDLzQNJLpkPmjZxZJ354aS5tWfyWTYSSWKzahBQ-ELAaGiwL43YhDtU9Fc7K8mWhbPBPFwR3cAR0MfVWKpwgFo35WeidRiOxKmyQvkBeXQsaGNuDs-iJJU",
            @instance[:http_cookiejar].get_cookies("http://localhost:99876/")[1].to_s
        end

        should "add cookies to next request" do
          next_request = Stampede::Modules::HTTP::Request.create(:get, "http://localhost:99876/").send(:new, @instance)
          assert_equal "PREF=ID=91e9acb4192bc78a:FF=0:TM=1300456190:LM=1300456190:S=fOrXavOfE1_3KuzY;" +
            "NID=45=AHVUp1ZHBPCDLzQNJLpkPmjZxZJ354aS5tWfyWTYSSWKzahBQ-ELAaGiwL43YhDtU9Fc7K8mWhbPBPFwR3cAR0MfVWKpwgFo35WeidRiOxKmyQvkBeXQsaGNuDs-iJJU",
            next_request.send(:collect_headers)["cookie"]
        end
      end

      context "with single cookie" do
        setup do
          setup_response "facebook.com"
        end

        should "set cookie in session" do
          assert_equal "datr=NyOGTWIxclv1czGUC7NyUt-A",
            @instance[:http_cookiejar].get_cookies("http://localhost:99876/")[0].to_s
        end
      end

      context "with invalid cookie" do
        setup do
          setup_response "facebook.com_invalid_cookie"
        end

        should "not set cookie in session" do
          assert_equal [], @instance[:http_cookiejar].get_cookies("http://localhost:99876/")
        end
      end
    end
  end
end
