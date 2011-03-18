require "active_support/concern"
require "pp"

module Stampede
  module Process::Verbose
    extend ActiveSupport::Concern

    included do
      before_start do
        logger.log logger.bright_color(">>", :yellow) << logger.color(" Starting ", :white) <<
          logger.bright_color(process_name, :yellow) << logger.color(" (#{object_id.to_s(16)}, #{self.class}).", :white)
      end

      after_finish do
        logger.log logger.bright_color("<<", :green) << logger.color(" Finished ", :white) <<
          logger.bright_color(process_name, :green) << logger.color(" (#{object_id.to_s(16)}, #{self.class}).", :white)
      end

      alias_method :record_without_logging, :record
      def record(data)
        logger.log logger.bright_color("==", :cyan) << logger.color(" Recorded ", :white) <<
          logger.bright_color(process_name, :cyan) << logger.color(" (#{object_id.to_s(16)}, #{self.class}).", :white) <<
          logger.color("\n   Attributes: #{data.keys.map(&:to_s).sort.join(", ")}.", :white)
        logger.log logger.color(data.pretty_inspect, :white)

        record_without_logging(data)
      end

      # Process::Reporting.module_eval do
      #   alias_method :report_without_logging, :report
      #   def report(data)
      #     logger.log logger.bright_color(" -", :cyan) << logger.color(" Reported ", :white) <<
      #       logger.bright_color(process_name, :cyan) << logger.color(" (#{object_id.to_s(16)}, #{self.class}).", :white) <<
      #       logger.color("\n   Attributes: #{data.keys.map(&:to_s).sort.join(", ")}.", :white)
      #
      #     report_without_logging(data)
      #   end
      # end
    end
  end
end
