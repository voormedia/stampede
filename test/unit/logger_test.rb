require "helper"

class LoggerTest < Test::Unit::TestCase
  context "logger" do
    setup do
      @out = StringIO.new
      class << @out
        alias_method :write_nonblock, :write
      end
    end

    subject { Stampede::Logger.new(@out) }

    context "when logged to" do
      setup { subject.log "something happened" }

      should "buffer data" do
        assert_equal "", @out.string
      end

      context "and flushed" do
        setup { subject.flush }

        should "write data with newline" do
          assert_equal "something happened\n", @out.string
        end
      end

      context "in large amounts" do
        setup { 1000.times { subject.log "something happened" } }

        should "auto flush" do
          assert_match /something happened\n/, @out.string
        end
      end
    end
  end
end
