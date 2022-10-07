# frozen_string_literal: true

module JobWatcher
  def perform(key)
    Timeout.timeout(self.class.get_sidekiq_options['timeout'] || 1.hour) do
      super(key)
    end
  end
end
