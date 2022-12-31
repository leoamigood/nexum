# frozen_string_literal: true

module JobBenchmarker
  include Tracer

  def perform(*args)
    time = Benchmark.measure { super(*args) }
    trace(:benchmark, args.join(','), value: time.real)
  end
end
