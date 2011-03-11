require File.expand_path("helper", File.dirname(__FILE__))

class ExampleProcess < Stampede::Process
  def start
    finish
  end
end

N = 200_000

def work
  process = ExampleProcess.new
  N.times { process.run }
  true
end

Benchmark.bmbm do |bm|
  bm.report "running" do
    work
  end
end

GC.start
ObjectSpace.each_object(ExampleProcess) do |o|
  p o
end
