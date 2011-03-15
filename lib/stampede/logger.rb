module Stampede
  class Logger
    DEFAULT_BUFFER_SIZE = 8192

    def initialize(path_or_io, options = {})
      @io = if path_or_io.respond_to? :read
        path_or_io
      else
        File.open(path_or_io, "w+")
      end
      @closing = false
      @buffer_size = options[:buffer_size] || DEFAULT_BUFFER_SIZE
      @colorize = options[:colorize]
      reset_buffer
    end

    def log(msg)
      @buffer << (msg << "\n")
      flush if @buffer.size > @buffer_size
    end

    def flush
      return if @writing
      write_buffer
    end

    def close
      @closing = true
      @close_callback = Proc.new
      flush
    end

    def close!
      write_buffer_blocking
    end

    def color(string, color)
      return string unless @colorize
      string.color(color)
    end

    def bright_color(string, color)
      return string unless @colorize
      string.color(color).bright
    end

    private

    def write_buffer
      return unless @io
      @writing = true
      @offset += (@io.write_nonblock @buffer[@offset..-1] rescue 0)
      if @offset < @buffer.length
        EM.next_tick { write_buffer }
      else
        reset_buffer
        @close_callback.call if @closing
        @writing = false
      end
    end

    def write_buffer_blocking
      return unless @io
      @io.write @buffer[@offset..-1]
    end

    def reset_buffer
      @buffer = ""
      @offset = 0
    end
  end
end
