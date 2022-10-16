# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :be_traced do |options|
  match do |event|
    expect(event).to be
    expect(event.tracer).to eq(described_class.name)

    options || [].each do |key, value|
      expect(event.send(key)).to eq(value)
    end
  end
end
