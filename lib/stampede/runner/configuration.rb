module Stampede
  class Runner::Configuration
    def initialize(config = {})
      @config = config
    end

    def max_connections
      @config[:max_connections] or @config[:"max-connections"]
    end

    def colorize?
      @config[:colors] or !@config[:"no-colors"]
    end

    def daemonize?
      @config[:daemonize]
    end

    def verbose?
      @config[:verbose]
    end

    def logger
      if daemonize?
        Logger.new "stampede.log", :colorize => colorize?
      else
        Logger.new $stdout, :buffer_size => 0, :colorize => colorize?
      end
    end

    def reporter
      Reporters::CouchDB.new @config[:output] || "http://localhost:5984/stampede"
    end
  end
end
