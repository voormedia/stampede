require "rubygems"
require "bundler"
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require "test/unit"

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), "..", "lib")))
require "stampede"
require "shoulda-context"
require "timecop"
require "unit/macros"
require "em-http-request"
# require "webmock/test_unit"

class Test::Unit::TestCase
  def fixture_path(path)
    File.expand_path(path, File.join(File.dirname(__FILE__), "fixtures"))
  end
end

class ExampleProcess < Stampede::Process
  def flagged?
    @flags > 0
  end

  def flag
    @flags = @flags.to_i + 1
  end

  def flags
    @flags
  end

  def start
    finish
  end

  alias_method :child_finished, :finish
end

class DummyRunner
  attr_accessor :reporter

  def initialize
    @reporter = DummyReporter.new
  end

  def finish
    EM.stop if EM.reactor_running?
  end
  alias_method :child_finished, :finish

  def runner
    self
  end
end

class DummyReporter
  attr_accessor :reported

  def initialize
    @reported = []
  end

  def report(name, data)
    @reported << { name => data }
  end
end
