# frozen_string_literal: true

module UserResourceJobTracer
  include ResourceJobTracer

  def resource
    'user'
  end

  def domain
    Developer
  end
end
