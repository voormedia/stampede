require "helper"

class TestStampede < Test::Unit::TestCase
  context "stampede" do
    context "version" do
      should "be a string" do
        assert_kind_of String, Stampede.version
      end
    end

    context "banner" do
      should "be a string" do
        assert_kind_of String, Stampede.banner
      end
    end
  end
end
