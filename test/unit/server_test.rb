require "helper"

class ServerTest < Test::Unit::TestCase
  context "server" do
    subject { Stampede::Server }

    setup do
      @stdout = $stdout = StringIO.new
    end

    teardown do
      $stdout = STDOUT
    end

    context "when started" do
      setup do
        subject.start ["start", fixture_path("scenarios/simple.stampede")]
      end

      should "start runner" do
        assert_equal 1, ObjectSpace.each_object(Stampede::Runner).to_a.length
      end
    end

    context "when asked for version" do
      setup do
        subject.start ["-v"]
      end

      should "display version" do
        assert_equal "#{Stampede.banner}\n", @stdout.string
      end
    end
  end
end
