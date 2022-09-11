# frozen_string_literal: true

module RepoResourceJobTracer
  include ResourceJobTracer

  def trace_by
    { key: 'full_name', resource: 'repo' }
  end

  def domain
    Repository
  end
end
