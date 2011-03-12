require "thor"

module Stampede
  class Server < Thor
    desc "start SCENARIO", "Starts the given scenario"
    method_option "verbose", :aliases => "-v", :type => :boolean, :desc => "Be verbose about which actions are executed"
    def start(scenario)
      setup_verbose_callbacks if options[:verbose]
      Runner.start Scenario.load(scenario), Reporters::Console.new
    end

    private

    def setup_verbose_callbacks
      Process.class_eval do
        def depth
          @depth ||= begin
            ctx = self
            level = -1
            level += 1 while ctx.respond_to? :context and ctx = ctx.context
            level
          end
        end

        before_start { $stderr.puts "  " * depth + "\033[1;30m>> #{name} (#{self.class.name})\033[0;0m" }
        after_finish { $stderr.puts "  " * depth + "\033[1;30m<< #{name} (#{self.class.name})\033[0;0m" }
      end
    end
  end
end
