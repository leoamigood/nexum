# frozen_string_literal: true

module UserResourceJobTracer
  include ResourceJobTracer

  def resource
    Developer
  end
end
