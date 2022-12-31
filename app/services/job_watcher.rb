# frozen_string_literal: true

module JobWatcher
  include Tracer

  def perform(*args)
    Timeout.timeout(self.class.get_sidekiq_options['timeout'] || 1.hour) do
      super(*args)
    end
  rescue Timeout::Error => e
    trace(:warning, args.join(','), message: e.message)
    raise e
  end
end
