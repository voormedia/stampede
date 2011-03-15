require "helper"

class JSONTest < Test::Unit::TestCase
  context "json  reporter" do
    setup do
      @out = StringIO.new
      class << @out
        alias_method :write_nonblock, :write
      end
    end

    subject { Stampede::Reporters::JSON.new(@logger = Stampede::Logger.new(@out)) }

    context "when reported to" do
      setup do
        subject.record :variable => "value"
        @logger.flush
      end

      should "serialize to json" do
        assert_equal "[{\"variable\":\"value\"}]\n", @out.string
      end
    end
  end
end
