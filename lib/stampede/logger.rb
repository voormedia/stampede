require "stringio"

module Stampede
  class Logger
    def initialize(path_or_io)
      @io = if path_or_io.respond_to? :read
        path_or_io
      else
        File.open(path_or_io, "w+")
      end
      reset_buffer
    end

    BUFFER_SIZE = 8192

    def log(msg)
      @buffer << (msg << "\n")
      flush if @buffer.size > BUFFER_SIZE
    end

    def flush
      return if @flushing
      write_data
    end

    private

    def write_data
      return unless @io
      @flushing = true
      @offset += (@io.write_nonblock @buffer[@offset..-1] rescue 0)
      if @offset < @buffer.length
        EM.next_tick { write_data }
      else
        reset_buffer
        @flushing = false
      end
    end

    def reset_buffer
      @buffer = ""
      @offset = 0
    end
  end
end
