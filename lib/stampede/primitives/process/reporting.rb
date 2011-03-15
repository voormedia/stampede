module Stampede
  # Report data to the current context.
  module Process::Reporting
    def self.included(base)
      base.before_start do
        create_report
      end

      base.after_finish do
        send_report
      end
    end

    protected

    def create_report
      @report = {}
    end

    def send_report
      runner.reporter.report "#{process_name}", @report unless @report.empty?
    end

    def report(data = {})
      @report.merge! data
    end
  end
end
