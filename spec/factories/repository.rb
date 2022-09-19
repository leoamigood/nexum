# frozen_string_literal: true

FactoryBot.define do
  factory :repository do
    developer       { build(:developer) }

    name            { FFaker::Name.name }
    owner_name      { FFaker::Internet.user_name }
    full_name       { "#{owner_name}/#{name}" }
    node_id         { FFaker::Lorem.characters(40) }
  end
end
