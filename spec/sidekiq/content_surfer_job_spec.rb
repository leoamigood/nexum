# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

describe ContentSurferJob do
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
      let(:repo) { build(:octokit, :repo, full_name: 'leoamigood/aktiverum') }
      let(:dependencies) do
        [
          Dependabot::Dependency.new(
            name:            'rails',
            version:         '7.0.3.1',
            requirements:    [requirement: '~> 7.0.3, >= 7.0.3.1', file: 'Gemfile', source: nil, groups: [:default]],
            package_manager: 'bundler'
          )
        ]
      end

      before do
        allow_any_instance_of(described_class).to receive(:resolve_dependencies).and_return(dependencies)
      end

      context 'when repository language is processable' do
        let!(:repository) { create(:repository, language: 'Ruby', full_name: repo.full_name) }

        it 'content job succeeded' do
          described_class.perform_async(repo.full_name)

          expect(Trace.find_by(name: repo.full_name, state: Enum::TraceState::ATTEMPTED)).to be_traced
          expect(Trace.find_by(name: repo.full_name, state: Enum::TraceState::SKIPPED)).not_to be_traced
          expect(Trace.find_by(name: repo.full_name, state: Enum::TraceState::SUCCEEDED)).to be_traced
          expect(Trace.find_by(name: repo.full_name, state: Enum::TraceState::FAILED)).not_to be_traced
        end

        it 'repository libraries determined' do
          expect do
            described_class.perform_async(repo.full_name)
            expect(Library.find_by(repository_id: repository.id, name: 'rails', version: '7.0.3.1', manager: 'bundler')).to be
          end.to change(Library, :count).by(1)
        end
      end
    end
  end
end
