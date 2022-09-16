# frozen_string_literal: true

module JobWatcher
  def perform(key)
    Timeout::timeout(sidekiq_options_hash['timeout']) do
      super(key)
    end
  end
end
