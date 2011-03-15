require File.expand_path("helper", File.dirname(__FILE__))
require "tempfile"
require "eventmachine"

N = 40_000

def work(logger)
  EM.run {
    EM.set_quantum 20
    file1 = Tempfile.new("test")
    file2 = Tempfile.new("test")
    logger1 = logger.new file1
    logger2 = logger.new file2
    N.times {
      logger1.log "ASDF ASDF ASDF ASDF ASDF" * 2
      logger1.log "ZXCV ZXCV ZXCV ZXCV ZXCV"
      logger2.log "ASDF ASDF ASDF ASDF ASDF" * 2
      logger2.log "ZXCV ZXCV ZXCV ZXCV ZXCV"
      logger1.log "ASDF ASDF ASDF ASDF ASDF" * 250
      logger2.log "ZXCV ZXCV ZXCV ZXCV ZXCV"
      logger1.log "ASDF ASDF ASDF ASDF ASDF" * 2
      logger2.log "ZXCV ZXCV ZXCV ZXCV ZXCV"
      logger2.log "ASDF ASDF ASDF ASDF ASDF" * 2
      logger1.log "ZXCV ZXCV ZXCV ZXCV ZXCV"
      logger1.log "ASDF ASDF ASDF ASDF ASDF" * 10
      logger2.log "ZXCV ZXCV ZXCV ZXCV ZXCV" * 3
      logger2.log "ASDF ASDF ASDF ASDF ASDF" * 2
      logger1.log "ZXCV ZXCV ZXCV ZXCV ZXCV"
      logger1.log "ASDF ASDF ASDF ASDF ASDF" * 10
      logger2.log "ZXCV ZXCV ZXCV ZXCV ZXCV" * 3
      logger1.log "ASDF ASDF ASDF ASDF ASDF" * 250
      EM.stop
    }
    p File::Stat.new(file1.path).blocks
    p File::Stat.new(file2.path).blocks
    true
  }
end

class Logger2
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
    @buffer.pos = @offset.to_i
    @offset += (@io.write_nonblock @buffer.read) # rescue 0)
    if @offset < @buffer.length
      p "missed"
      EM.next_tick { write_data }
    else
      reset_buffer
      @flushing = false
    end
  end

  def reset_buffer
    @buffer = StringIO.new
    @offset = 0
  end
end


Benchmark.bmbm do |bm|
  bm.report "logger" do
    work(Stampede::Logger)
  end

  bm.report "logger2" do
    work(Logger2)
  end
end
