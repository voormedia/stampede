require "thor"

module Stampede
  class Server < Thor
    desc "start SCENARIO", "Starts the given scenario"
    def start(scenario)
      Runner.start Scenario.load(scenario), Reporters::Console.new
    end
  end
end
