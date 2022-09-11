# frozen_string_literal: true

module ResourceJobTracer
  def perform(key)
    trace(:attempted, key)
    if domain.recently_visited?(key)
      Rails.logger.info "#{domain.name} data is recent - skipping #{self.class.name} execution."
      trace(:skipped, key)
    else
      trace(:in_progress, key)

      super(key)

      trace(:succeeded, key)
    end
  rescue StandardError => e
    trace(:failed, key, message: e.message)
    raise e
  end

  def trace(state, value, attributes = {})
    raise NotAcceptableTraceStateError unless Enum::TraceState.value?(state.to_s)

    Trace.create!(attributes.merge(value:, state:).merge(trace_by))
  end

  def trace_by
    raise NotImplementedError
  end

  def domain
    NotImplementedError
  end
end
