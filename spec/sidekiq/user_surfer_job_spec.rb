# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

describe UserSurferJob do
  specify { is_expected.to be_processed_in :low }
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

    context 'when developer resource not found' do
      before do
        allow_any_instance_of(Octokit::Client).to receive(:user).and_raise(Octokit::NotFound)
      end

      let(:username) { 'not_found_username' }

      it 'user surfer job finishes fast' do
        expect do
          described_class.perform_async(username)
        end.to avoid_changing(Developer, :count).and raise_error(Octokit::NotFound)
      end

      it 'surf trace records failed state' do
        expect { described_class.perform_async(username) }.to raise_error(Octokit::NotFound)

        expect(Trace.find_by(name: username, state: Enum::TraceState::ATTEMPTED)).to be_traced
        expect(Trace.find_by(name: username, state: Enum::TraceState::SKIPPED)).not_to be_traced
        expect(Trace.find_by(name: username, state: Enum::TraceState::SUCCEEDED)).not_to be_traced
        expect(Trace.find_by(name: username, state: Enum::TraceState::FAILED)).to be_traced(value: 'not_found_username', message: 'Octokit::NotFound')
      end
    end

    context 'when developer account with followers successfully discovered' do
      let(:user) { build(:octokit, :user) }
      let(:follower) { build(:octokit, :user) }
      let(:following) { build(:octokit, :user) }

      before do
        allow_any_instance_of(Octokit::Client).to receive(:repos).and_return([])
        allow_any_instance_of(Octokit::Client).to receive(:last_response).and_return(OpenStruct.new(rels: {}))

        allow_any_instance_of(Octokit::Client).to receive(:user).with(user.login).and_return(user)
        allow_any_instance_of(Octokit::Client).to receive(:followers).with(user.login, per_page: 100).and_return([follower])
        allow_any_instance_of(Octokit::Client).to receive(:following).with(user.login, per_page: 100).and_return([following])

        allow(RepoSurferJob).to receive(:perform_async)
        allow_any_instance_of(Octokit::Client).to receive(:user).with(follower.login).and_return(follower)
        allow_any_instance_of(Octokit::Client).to receive(:followers).with(follower.login, per_page: 100).and_return([])
        allow_any_instance_of(Octokit::Client).to receive(:following).with(follower.login, per_page: 100).and_return([])

        allow_any_instance_of(Octokit::Client).to receive(:user).with(following.login).and_return(following)
        allow_any_instance_of(Octokit::Client).to receive(:followers).with(following.login, per_page: 100).and_return([])
        allow_any_instance_of(Octokit::Client).to receive(:following).with(following.login, per_page: 100).and_return([])
      end

      it 'developer info is persisted' do
        expect do
          described_class.perform_async(user.login)
        end.to change(Developer, :count).by(3)
      end

      it 'followers are queued to be surfed' do
        described_class.perform_async(user.login)

        expect(RepoSurferJob).to have_received(:perform_async).with(follower.login)
        expect(RepoSurferJob).to have_received(:perform_async).with(following.login)
      end

      it 'surf trace records attempted and succeeded states' do
        described_class.perform_async(user.login)

        expect(Trace.find_by(name: user.login, state: Enum::TraceState::ATTEMPTED)).to be_traced
        expect(Trace.find_by(name: user.login, state: Enum::TraceState::SKIPPED)).not_to be_traced
        expect(Trace.find_by(name: user.login, state: Enum::TraceState::SUCCEEDED)).to be_traced
        expect(Trace.find_by(name: user.login, state: Enum::TraceState::FAILED)).not_to be_traced
      end

      context 'when developer has been recently visited' do
        let!(:developer) { create(:developer, :recently_visited, username: user.login) }

        it 'skip surfing this developer and his follows' do
          described_class.perform_async(user.login)

          expect(RepoSurferJob).not_to have_received(:perform_async)
        end

        it 'skip surfing this developer and adds the trace' do
          described_class.perform_async(user.login)

          expect(Trace.find_by(name: user.login, state: Enum::TraceState::ATTEMPTED)).to be_traced
          expect(Trace.find_by(name: user.login, state: Enum::TraceState::SKIPPED)).to be_traced
          expect(Trace.find_by(name: user.login, state: Enum::TraceState::SUCCEEDED)).not_to be_traced
          expect(Trace.find_by(name: user.login, state: Enum::TraceState::FAILED)).not_to be_traced
        end

        context 'when refresh is forced' do
          it 'updates developer attributes' do
            expect do
              described_class.perform_async(user.login, 'refresh' => true)

              expect(developer.reload.email).to eq(user.email)
            end.to change(developer, :visited_at)
          end
        end
      end
    end
  end
end
