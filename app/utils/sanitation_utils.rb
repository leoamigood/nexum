# frozen_string_literal: true

class SanitationUtils
  class << self
    def sanitize_model(model)
      model.attributes.each do |k, v|
        sanitize_attribute(model, k, v)
      end
    end

    private

    def sanitize_attribute(model, key, value)
      return unless value.is_a?(String)

      model.send "#{key}=", remove_null_value(value)
    end

    def remove_null_value(value)
      value.delete("\u0000")
    end
  end
end
