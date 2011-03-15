module Stampede
  class Runner::Configuration
    def initialize(config = {})
      @config = config
    end

    def max_connections
      @config[:max_connections] or @config[:"max-connections"]
    end

    def daemonize?
      @config[:daemonize]
    end

    def verbose?
      @config[:verbose]
    end

    def logger
      Logger.new daemonize? ? "stampede.log" : $stdout
    end
  end
end
