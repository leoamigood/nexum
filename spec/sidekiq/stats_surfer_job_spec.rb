# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

describe StatsSurferJob do
  specify { is_expected.to be_processed_in :high }
  specify { is_expected.to be_retryable 3 }

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
      let(:repo) { build(:octokit, :repo) }

      before do
        allow_any_instance_of(Octokit::Client).to receive(:participation_stats).and_return(OpenStruct.new(owner: [0, 1, 5]))
      end

      context 'when repository has been recently visited' do
        let!(:repository) { create(:repository, :recently_visited, full_name: repo.full_name) }

        it 'ignore recently visited and surf repo' do
          described_class.perform_async(repo.full_name)

          expect(Trace.find_by(name: repo.full_name, state: Enum::TraceState::SKIPPED)).not_to be_traced
          expect(Trace.find_by(name: repo.full_name, state: Enum::TraceState::SUCCEEDED)).to be_traced
        end

        it 'calculates owner participation' do
          expect do
            described_class.perform_async(repo.full_name)
            repository.reload
          end.to change(repository, :participation).to(6)
        end
      end
    end
  end
end
