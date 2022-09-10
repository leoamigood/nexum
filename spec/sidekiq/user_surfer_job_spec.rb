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

    context 'when user resource not found' do
      before do
        allow_any_instance_of(Octokit::Client).to receive(:user).and_raise(Octokit::NotFound)
      end

      it 'user surfer job finishes fast' do
        expect do
          described_class.perform_async('not_found_username')
        end.not_to change(Elite, :count)
      end

      it 'surf trace records failed state' do
        expect do
          described_class.perform_async('not_found_username')

          trace = SurfTrace.last
          expect(trace.username).to eq('not_found_username')
          expect(trace.state).to eq(Enum::ResourceState::FAILED)
          expect(trace.message).to eq('Octokit::NotFound')

          states = SurfTrace.all.pluck(:state)
          expect(states).to eq(Enum::ResourceState::FAILURE_TRACE)
        end.to change(SurfTrace, :count).by(3)
      end
    end

    context 'when user resource successfully discovered' do
      let(:user) { build(:github_resource, :user) }

      before do
        allow_any_instance_of(Octokit::Client).to receive(:user).and_return(user)
        allow_any_instance_of(Octokit::Client).to receive(:repos).and_return([])
        allow_any_instance_of(Octokit::Client).to receive(:followers).and_return([])
        allow_any_instance_of(Octokit::Client).to receive(:following).and_return([])
      end

      it 'user info is persisted' do
        expect do
          described_class.perform_async('leoamigood')
        end.to change(Elite, :count).by(1)
      end

      it 'surf trace records attempted and succeeded states' do
        expect do
          described_class.perform_async('octokit')

          states = SurfTrace.all.pluck(:state)
          expect(states).to eq(Enum::ResourceState::SUCCESS_TRACE)
        end.to change(SurfTrace, :count).by(3)
      end
    end
  end
end
