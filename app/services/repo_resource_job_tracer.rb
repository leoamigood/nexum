# frozen_string_literal: true

module RepoResourceJobTracer
  include ResourceJobTracer

  def resource
    Repository
  end
end
