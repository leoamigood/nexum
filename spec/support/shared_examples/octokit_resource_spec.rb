# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'octokit_resource' do
  let(:job) { described_class.new }

  it 'initializes github octokit client with default token' do
    expect(job.client.access_token).to eq(Rails.application.credentials.github.access_token!)
  end

  context 'when token is specified' do
    before do
      allow(job).to receive(:token).and_return('token_value')
    end

    it 'initializes github octokit client with supplied token' do
      expect(job.client.access_token).to eq('token_value')
    end
  end
end
