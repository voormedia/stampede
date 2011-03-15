module Stampede
  VERSION = [0, 1, 0]

  class << self
    def version
      VERSION.join(".")
    end

    def banner
      @banner ||= "#{name}/#{version}"
    end

    def user_agent
      @user_agent ||= "#{banner} (#{RUBY_ENGINE rescue "ruby"} #{RUBY_VERSION}-#{RUBY_PATCHLEVEL}; #{RUBY_PLATFORM})"
    end

    def codename
      "Thundering Herd"
    end
  end

  autoload :Logger, "stampede/logger"
  autoload :Runner, "stampede/runner"
  autoload :Server, "stampede/server"

  module Reporters
    autoload :JSON, "stampede/reporters/json"
  end

  autoload :Process, "stampede/primitives/process"

  autoload :Group, "stampede/primitives/group"
  autoload :Queue, "stampede/primitives/queue"

  autoload :Scenario, "stampede/primitives/scenario"
  autoload :Session, "stampede/primitives/session"
  autoload :Action, "stampede/primitives/action"
  autoload :Lambda, "stampede/primitives/lambda"

  module Modules
    autoload :HTTP, "stampede/modules/http"
    autoload :Scheduling, "stampede/modules/scheduling"
  end
end
