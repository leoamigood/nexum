# frozen_string_literal: true

module JobWatcher
  include Tracer

  def perform(key)
    Timeout.timeout(self.class.get_sidekiq_options['timeout'] || 1.hour) do
      super(key)
    end
  rescue Timeout::Error => e
    trace(:warning, key, message: e.message)
  end
end
