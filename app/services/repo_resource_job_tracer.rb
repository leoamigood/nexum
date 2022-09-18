# frozen_string_literal: true

module RepoResourceJobTracer
  include ResourceJobTracer

  def resource
    'repo'
  end

  def domain
    Repository
  end
end
