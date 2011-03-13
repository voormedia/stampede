require "thor"

module Stampede
  class Server < Thor
    desc "start SCENARIO", "Starts the given scenario"
    method_option "verbose", :aliases => "-v", :type => :boolean, :desc => "Be verbose about which actions are executed"
    def start(scenario)
      Stampede.verbose! if options[:verbose]
      Runner.start Scenario.load(scenario), Reporters::Console.new
    end
  end
end
