# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

describe RepoSurferJob do
  specify { is_expected.to be_processed_in :medium }
  specify { is_expected.to be_retryable true }

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

    context 'when repositories discovered' do
      let!(:developer) { create(:developer, username: 'leoamigood') }
      let(:repos) { build_list(:octokit, 3, :repo) }

      context 'without pagination' do
        before do
          allow_any_instance_of(Octokit::Client).to receive(:repos).and_return(repos)
          allow_any_instance_of(Octokit::Client).to receive(:last_response).and_return(OpenStruct.new(rels: {}))

          allow(ContentSurferJob).to receive(:perform_async)
          allow(StatsSurferJob).to receive(:perform_async)
        end

        it 'content and stats surf initiated' do
          described_class.perform_async(developer.username)

          expect(ContentSurferJob).to have_received(:perform_async).exactly(3).times
          expect(StatsSurferJob).to have_received(:perform_async).exactly(3).times
        end

        it 'repository surf job succeeded' do
          described_class.perform_async(developer.username)

          expect(Trace.find_by(name: developer.username, state: Enum::TraceState::ATTEMPTED)).to be_traced
          expect(Trace.find_by(name: developer.username, state: Enum::TraceState::SKIPPED)).not_to be_traced
          expect(Trace.find_by(name: developer.username, state: Enum::TraceState::SUCCEEDED)).to be_traced
          expect(Trace.find_by(name: developer.username, state: Enum::TraceState::FAILED)).not_to be_traced
        end

        context 'fields include values requiring sanitation' do
          let(:repos) { [build(:octokit, :repo, description: "Unprocessable null value \u0000")] }

          it 'repository surf job succeeded' do
            described_class.perform_async(developer.username)

            expect(Trace.find_by(name: developer.username, state: Enum::TraceState::ATTEMPTED)).to be_traced
            expect(Trace.find_by(name: developer.username, state: Enum::TraceState::SKIPPED)).not_to be_traced
            expect(Trace.find_by(name: developer.username, state: Enum::TraceState::SUCCEEDED)).to be_traced
            expect(Trace.find_by(name: developer.username, state: Enum::TraceState::FAILED)).not_to be_traced
          end
        end

        context 'with existing repos' do
          let!(:repository) { create(:repository, developer:, id: repos.first.id) }

          it 'delete existing repos and creates new ones' do
            expect do
              described_class.perform_async(developer.username)
            end.to change(Repository, :count).by(2)
          end
        end

        context 'includes forked repo' do
          let(:forked) { build(:octokit, :repo, :forked) }

          before do
            allow_any_instance_of(Octokit::Client).to receive(:repos).and_return(repos << forked)
          end

          it 'excludes forked repo' do
            described_class.perform_async(developer.username)

            expect(ContentSurferJob).to have_received(:perform_async).exactly(3).times
            expect(StatsSurferJob).to have_received(:perform_async).exactly(3).times
          end
        end
      end
    end
  end
end
