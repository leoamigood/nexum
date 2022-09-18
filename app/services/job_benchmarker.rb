# frozen_string_literal: true

module JobBenchmarker
  include Tracer

  def perform(username)
    time = Benchmark.measure { super(username) }
    trace(:benchmark, username, value: time.real)
  end
end
