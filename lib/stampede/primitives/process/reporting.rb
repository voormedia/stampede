require "active_support/concern"

module Stampede
  # Report data to the current context.
  module Process::Reporting
    extend ActiveSupport::Concern

    included do
      before_start do
        @report = { :label => process_name }
      end

      after_finish do
        @context.record @report.freeze
      end
    end

    protected

    def report(data = {})
      @report.merge! data
    end

    def report_sequence(name, data = {})
      (@report[name] ||= []) << data
    end
  end
end
