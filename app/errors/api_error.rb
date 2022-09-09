# frozen_string_literal: true

class ApiError < StandardError
  attr_reader :code, :status, :metadata

  def initialize(code, status, metadata = {})
    @status = status
    @code = code
    @metadata = metadata

    super(self.class.message_for(code))
  end

  def serializable_hash
    {
      errors:   [message],
      code:,
      metadata: metadata.presence
    }.compact
  end

  def self.code_for(key)
    key
  end

  def self.message_for(key)
    I18n.t("errors.#{code_for(key)}")
  end

  def message
    return metadata if metadata.is_a? String

    metadata[:message].presence || super
  end
end
