# frozen_string_literal: true

class NotAcceptableTraceStateError < UnprocessableEntryError
  def initialize(metadata = {})
    super('not_acceptable_trace_state', metadata)
  end
end
