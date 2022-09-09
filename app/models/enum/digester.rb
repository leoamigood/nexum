# frozen_string_literal: true

module Enum
  module Digester
    def digest(value)
      self.value(value&.parameterize(separator: '_')&.upcase&.to_sym)
    end

    def digest_with_error(value, error)
      digested = digest(value)
      raise error.new(value:) if digested.blank?

      digested
    end
  end
end
