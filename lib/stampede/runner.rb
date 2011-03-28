require "eventmachine"
require "rainbow"

module Stampede
  # Run one or more scenarios.
  class Runner
    autoload :Daemonization, "stampede/runner/daemonization"
    autoload :Configuration, "stampede/runner/configuration"

    include Daemonization

    attr_reader :config, :logger, :reporter, :runner

    class << self
      def start(scenario, config)
        new(scenario, config).start
      end
    end

    def initialize(scenario, config)
      @scenario = scenario
      @config = Runner::Configuration.new(config)
      @logger = @config.logger
      @reporter = Reporters::CouchDB.new("http://localhost:5984/stampede")
      @runner = self
    end

    def start
      trap_signals
      set_max_connections
      verbose! if config.verbose?
      daemonize! if config.daemonize?

      logger.log "#{Stampede.banner} (#{Stampede.codename}) is starting..."
      logger.log "Running scenario '#{@scenario.process_name}'..."

      execute
    end

    def finish(exit_message = "Finished.")
      logger.log exit_message
      reporter.close { logger.close { EM.stop } }
    end
    alias_method :child_finished, :finish

    def abort(exit_message = "Aborted.")
      EM.stop
      logger.log logger.bright_color(exit_message, :red)
      logger.close!
      exit! 1
    end

    def record(data)
      @reporter.record({ :host => Mac.address }.merge(data))
    end

    private

    def trap_signals
      Signal.trap(:INT)  { abort "Interrupted!" }
      Signal.trap(:TERM) { abort "Terminated!" }
      Signal.trap(:HUP)  { }  # FIXME: Should reload.
    end

    def set_max_connections
      EM.set_descriptor_table_size config.max_connections
    end

    def verbose!
      Process.send :include, Process::Verbose
    end

    def execute
      EM.run do
        EM.set_quantum 50
        @scenario.run(self)
      end
    end
  end
end
