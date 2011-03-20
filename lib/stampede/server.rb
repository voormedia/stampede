require "thor"

module Stampede
  class Server < Thor
    class_option "no-colors", :type => :boolean, :desc => "Avoid ANSI colors in output."
    class_option "trace", :type => :boolean, :desc => "Show stack traces on errors."

    desc "start SCENARIO", "Starts scenario defined in the given file"
    long_desc <<-DOC
      Starts the scenario that is defined in the given scenario file.

      Try 'stampede help' to list all available tasks.
    DOC

    method_option "daemonize", :aliases => "-d", :type => :boolean,
      :desc => "Fork and become a daemon."

    method_option "max-connections", :aliases => "-c", :type => :numeric, :default => 10_000,
      :desc => "Maximum number of connections that can be opened simultaneously."

    method_option "verbose", :aliases => "-v", :type => :boolean,
      :desc => "Be very verbose about which actions are executed."

    def start(scenario)
      Runner.start Scenario.from_file(scenario), options
    rescue Exception => e
      $stderr.puts e
      $stderr.puts e.backtrace if options[:trace]
    end

    desc "quickstart", "Quick start guide", :hide => true

    def quickstart
      help :start
    end

    desc "version", "Display version number"

    def version
      $stdout.puts Stampede.banner
    end

    default_task :quickstart

    map "-v" => :version
  end
end
