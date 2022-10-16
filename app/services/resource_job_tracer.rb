# frozen_string_literal: true

module ResourceJobTracer
  include Tracer

  def perform(name)
    trace(:attempted, name)
    super(name)
    trace(:succeeded, name)
  rescue SkipSurfException
    trace(:skipped, name)
  rescue StandardError => e
    trace(:failed, name, message: e.message)
    raise e
  end
end
