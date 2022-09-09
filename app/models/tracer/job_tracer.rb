# frozen_string_literal: true

module Tracer
  module JobTracer
    def perform(username)
      SurfTrace.attempt(username)
      resource = super
      SurfTrace.succeed(resource)
    rescue Octokit::NotFound => e
      SurfTrace.failed(username:, message: e.message)
    end
  end
end
