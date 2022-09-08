# frozen_string_literal: true

FactoryBot.define do
  factory :elite do
    username { FFaker::Internet.user_name }
  end
end
