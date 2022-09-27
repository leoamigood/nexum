# frozen_string_literal: true

module Tracer
  def trace(state, name, attributes = {})
    raise UnknownTraceActionError unless Enum::TraceState.value?(state.to_s)

    Trace.create!(attributes.merge(name:, state:, tracer: self.class.name))
  end
end
