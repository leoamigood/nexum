# frozen_string_literal: true

module Tracer
  def trace(state, username, attributes = {})
    raise NotAcceptableTraceStateError unless Enum::TraceState.value?(state.to_s)

    Trace.create!(attributes.merge(username:, state:, resource:))
  end

  def resource
    raise NotImplementedError
  end
end
