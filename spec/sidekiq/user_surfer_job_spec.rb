# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

describe UserSurferJob do
  it { is_expected.to be_processed_in :surfer }
  it { is_expected.to be_retryable true }

  context 'when job is enqueued' do
    before do
      Sidekiq::Testing.fake!
    end

    it 'queue increases in size' do
      expect do
        described_class.perform_async('username')
      end.to change(described_class.jobs, :size).by(1)
    end
  end

  context 'when job is executed' do
    before do
      Sidekiq::Testing.inline!
    end

    after do
      Sidekiq::Testing.fake!
    end

    context 'when root user not found' do
      before do
        allow_any_instance_of(Octokit::Client).to receive(:user).and_raise(Octokit::NotFound)
        allow(UserFollowersJob).to receive(:perform_async)
      end

      it 'user surfer job finishes fast' do
        expect(UserFollowersJob).not_to receive(:perform_async)

        described_class.perform_async('not_found_username')
      end
    end
  end
end
