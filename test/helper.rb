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

class Test::Unit::TestCase
  def fixture_path(path)
    File.expand_path(path, File.join(File.dirname(__FILE__), "fixtures"))
  end
end

class ExampleProcess < Stampede::Process
  def flagged?
    @flagged
  end

  def flag
    @flagged = true
  end

  def start
    finish
  end
end
