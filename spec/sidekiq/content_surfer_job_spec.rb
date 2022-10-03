# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

describe ContentSurferJob do
  specify { is_expected.to be_processed_in :high }
  specify { is_expected.to be_retryable true }

  context 'when job is enqueued' do
    before do
      Sidekiq::Testing.fake!
    end

    it 'queue increases in size' do
      expect do
        described_class.perform_async('username/repo_name')
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

    context 'when repository discovered' do
      let(:repo) { build(:octokit, :repo, full_name: 'leoamigood/aktiverum') }

      before do
        allow_any_instance_of(Octokit::Client).to receive(:contents)
      end

      context 'when repository language is processable' do
        let!(:repository) { create(:repository, language: 'Ruby', full_name: repo.full_name) }

        xit 'repository project queued for packages surfing' do
          described_class.perform_async(repo.full_name)
        end
      end
    end
  end
end
