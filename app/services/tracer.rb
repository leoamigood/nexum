# frozen_string_literal: true

module Tracer
  def trace(state, name, attributes = {})
    raise NotAcceptableTraceStateError unless Enum::TraceState.value?(state.to_s)

    Trace.create!(attributes.merge(name:, state:, resource: self.class.name))
  end

  def resource
    raise NotImplementedError
  end
end
