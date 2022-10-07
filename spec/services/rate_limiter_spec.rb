# frozen_string_literal: true

require 'rails_helper'

describe RateLimiter do
  context 'with no rate limits discovered' do
    before do
      described_class.limits = nil
    end

    context 'when queues are empty' do
      before do
        described_class.queues = {}
      end

      it 'rate is limited for all' do
        expect(described_class.limited?(:high)).to be(true)
        expect(described_class.limited?(:medium)).to be(true)
        expect(described_class.limited?(:low)).to be(true)
      end
    end

    context 'when queues are non empty' do
      before do
        described_class.queues = { 'critical' => 1, 'high' => 500, 'medium' => 200, 'low' => 1000 }
      end

      it 'rate is limited for all' do
        expect(described_class.limited?(:high)).to be(true)
        expect(described_class.limited?(:medium)).to be(true)
        expect(described_class.limited?(:low)).to be(true)
      end
    end
  end

  context 'with high rate limits' do
    before do
      described_class.limits = Octokit::RateLimit.new(5000, 4999)
    end

    context 'when queues are empty' do
      before do
        described_class.queues = {}
      end

      it 'rate is unlimited for all' do
        expect(described_class.limited?(:high)).to be(false)
        expect(described_class.limited?(:medium)).to be(false)
        expect(described_class.limited?(:low)).to be(false)
      end
    end

    context 'when queues are non empty' do
      before do
        described_class.queues = { 'critical' => 1, 'high' => 500, 'medium' => 200, 'low' => 1000 }
      end

      it 'rate is unlimited for high queue' do
        expect(described_class.limited?(:high)).to be(false)
        expect(described_class.limited?(:medium)).to be(true)
        expect(described_class.limited?(:low)).to be(true)
      end
    end
  end

  context 'with too low rate limits' do
    before do
      described_class.limits = Octokit::RateLimit.new(5000, 250)
    end

    context 'when queues are empty' do
      before do
        described_class.queues = {}
      end

      it 'rate is limited for all' do
        expect(described_class.limited?(:high)).to be(true)
        expect(described_class.limited?(:medium)).to be(true)
        expect(described_class.limited?(:low)).to be(true)
      end
    end

    context 'when queues are non empty' do
      before do
        described_class.queues = { 'critical' => 1, 'high' => 500, 'medium' => 200, 'low' => 1000 }
      end

      it 'rate is limited for all' do
        expect(described_class.limited?(:high)).to be(true)
        expect(described_class.limited?(:medium)).to be(true)
        expect(described_class.limited?(:low)).to be(true)
      end
    end
  end
end
