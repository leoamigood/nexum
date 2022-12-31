# frozen_string_literal: true

module ResourceJobTracer
  include Tracer

  def perform(*args)
    trace(:attempted, args.join(','))
    super(*args)
    trace(:succeeded, args.join(','))
  rescue SkipSurfException
    trace(:skipped, args.join(','))
  rescue StandardError => e
    trace(:failed, args.join(','), message: e.message)
    raise e
  end
end
