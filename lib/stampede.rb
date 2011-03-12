require "eventmachine"

module Stampede
  VERSION = [0, 1, 0]

  class << self
    def version
      VERSION.join(".")
    end

    def banner
      @banner ||= "#{name}/#{version} (#{RUBY_ENGINE rescue "ruby"} #{RUBY_VERSION}-#{RUBY_PATCHLEVEL}; #{RUBY_PLATFORM})"
    end
  end

  autoload :Runner, "stampede/runner"
  autoload :Server, "stampede/server"

  module Reporters
    autoload :Console, "stampede/reporters/console"
  end

  autoload :Process, "stampede/primitives/process"

  autoload :Group, "stampede/primitives/group"
  autoload :Queue, "stampede/primitives/queue"

  autoload :Scenario, "stampede/primitives/scenario"
  autoload :Session, "stampede/primitives/session"
  autoload :Action, "stampede/primitives/action"
  autoload :Lambda, "stampede/primitives/lambda"
end
