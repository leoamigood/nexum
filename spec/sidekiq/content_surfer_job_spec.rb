# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

describe ContentSurferJob do
  let(:repo) { build(:octokit, :repo, full_name: 'leoamigood/aktiverum') }

  specify { is_expected.to be_processed_in :high }
  specify { is_expected.to be_retryable 3 }

  it_behaves_like 'octokit_resource'

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

    context 'when repository discovered for supported language' do
      let!(:repository) { create(:repository, language: Enum::Language::RUBY, full_name: repo.full_name) }

      context 'with dependencies resolving mocked' do
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

        it 'content job succeeds' do
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

    context 'when repository discovered for unsupported language' do
      let!(:repository) { create(:repository, language: 'C++', full_name: repo.full_name) }

      describe '#resolve_dependencies' do
        it 'dependency resolving has trace warning' do
          described_class.perform_async(repo.full_name)

          expect(Trace.find_by(name: repo.full_name, state: Enum::TraceState::WARNING)).to be_traced(value: DependenciesResolveError.name)
        end
      end
    end
  end

  describe '#resolve_dependencies' do
    let!(:repository) { create(:repository, language: Enum::Language::RUBY, full_name: repo.full_name) }

    context 'when dependency files discovered' do
      let(:contents) { %w[Gemfile Gemfile.lock].map { |name| OpenStruct.new(name:) } }

      before do
        allow_any_instance_of(Octokit::Client).to receive(:contents).with(repository.full_name).and_return(contents)

        allow_any_instance_of(Dependabot::Bundler::FileFetcher).to receive(:files).and_return(contents)
        allow_any_instance_of(Dependabot::Bundler::FileParser).to receive(:parse)
      end

      it 'dependency resolving succeeds' do
        expect_any_instance_of(Dependabot::Bundler::FileFetcher).to receive(:files).once
        expect_any_instance_of(Dependabot::Bundler::FileParser).to receive(:parse).once

        described_class.new.resolve_dependencies(repository)
      end
    end

    context 'when dependency discovery fails' do
      before do
        allow_any_instance_of(Octokit::Client).to receive(:contents).with(repository.full_name).and_return({})
      end

      it 'dependency resolving includes trace warning' do
        described_class.new.resolve_dependencies(repository)

        expect(Trace.find_by(name: repo.full_name, state: Enum::TraceState::WARNING)).to be_traced(value: Dependabot::DependabotError.name)
      end
    end
  end
end
