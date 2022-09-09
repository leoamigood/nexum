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
        allow(UserFollowersJob).to receive(:perform_async)
      end

      it 'user surfer job finishes fast' do
        described_class.perform_async('not_found_username')

        expect(UserFollowersJob).not_to have_received(:perform_async)
      end

      it 'surf trace records failed state' do
        expect do
          described_class.perform_async('not_found_username')

          attempt = SurfTrace.first
          expect(attempt.username).to eq('not_found_username')
          expect(attempt.state).to eq(Enum::ResourceState::ATTEMPTED)

          failure = SurfTrace.last
          expect(failure.username).to eq('not_found_username')
          expect(failure.state).to eq(Enum::ResourceState::FAILED)
          expect(failure.message).to eq('Octokit::NotFound')
        end.to change(SurfTrace, :count).by(2)
      end
    end

    context 'when user resource successfully discovered' do
      let(:user) { build(:user_resource) }

      before do
        allow_any_instance_of(Octokit::Client).to receive(:user).and_return(user)
        allow(UserFollowersJob).to receive(:perform_async)
      end

      it 'user info is persisted' do
        expect do
          described_class.perform_async('octokit')
        end.to change(UserResource, :count).by(1)
      end

      it 'surf trace records attempted and succeeded states' do
        expect do
          described_class.perform_async('octokit')

          traces = SurfTrace.all
          expect(traces.first.state).to eq(Enum::ResourceState::ATTEMPTED)
          expect(traces.second.state).to eq(Enum::ResourceState::IN_PROGRESS)
          expect(traces.last.state).to eq(Enum::ResourceState::SUCCEEDED)
        end.to change(SurfTrace, :count).by(3)
      end
    end
  end
end
