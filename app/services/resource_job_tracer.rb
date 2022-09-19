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
  rescue StandardError => e
    trace(:failed, username, message: e.message, value: e.class.name)
    raise e
  end

  def ignore_recency?
    defined?(super) ? super : false
  end

  def domain
    NotImplementedError
  end
end
