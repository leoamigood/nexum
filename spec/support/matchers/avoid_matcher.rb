# frozen_string_literal: true

require "rspec/expectations"

RSpec::Matchers.define_negated_matcher :avoid_changing, :change
