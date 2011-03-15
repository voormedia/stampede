module Stampede
  # Records that start and end time of a process.
  module Process::Timing
    def self.included(base)
      base.before_start do
        start_timer
      end

      base.before_finish do
        stop_timer
        report :start => start_time, :stop => stop_time, :elapsed => elapsed
      end
    end

    protected

    # The time the process was started.
    attr_reader :start_time

    # The time the process finished.
    attr_reader :stop_time

    # The number of seconds that have elapsed between start and finish.
    attr_reader :elapsed

    # Starts the timer. Automatically called before the process starts.
    def start_timer
      @start_time = Time.now
    end

    # Stops the timer. Automatically called when the process finishes.
    def stop_timer
      @stop_time = Time.now
      @elapsed = ((@stop_time - @start_time) * 1000).round
    end
  end
end
