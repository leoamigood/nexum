# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

describe ViewRefreshJob do
  specify { is_expected.to be_processed_in :periodical }
  specify { is_expected.to be_retryable false }

  context 'when job is enqueued' do
    before do
      Sidekiq::Testing.fake!
    end

    it 'queue increases in size' do
      expect do
        described_class.perform_async('table' => 'repositories_stats', 'concurrently' => true)
      end.to change(described_class.jobs, :size).by(1)
    end
  end
end
