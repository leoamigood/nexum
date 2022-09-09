# frozen_string_literal: true

class NotAcceptableResourceStateError < UnprocessableEntryError
  def initialize(metadata = {})
    super('not_acceptable_resource_state', metadata)
  end
end
