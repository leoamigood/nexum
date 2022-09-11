# frozen_string_literal: true

module UserResourceJobTracer
  include ResourceJobTracer

  def trace_by
    { key: 'username', resource: 'user' }
  end

  def domain
    Developer
  end
end
