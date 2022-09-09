# frozen_string_literal: true

class UnprocessableEntryError < ApiError
  def initialize(code, metadata = {})
    super(code, :unprocessable_entity, metadata)
  end
end
