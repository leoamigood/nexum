# frozen_string_literal: true

module ResourceJobTracer
  include Tracer

  def perform(username)
    trace(:attempted, username)
    if resource.recently_visited?(username) && !ignore_recency?
      trace(:skipped, username)
    else
      trace(:in_progress, username)

      super(username)

      trace(:succeeded, username)
    end
  rescue => e
    trace(:failed, username, message: e.message, value: resource)
    raise e
  end

  def ignore_recency?
    defined?(super) ? super : false
  end

  def resource
    raise NotImplementedError
  end
end
