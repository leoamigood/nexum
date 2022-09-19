# frozen_string_literal: true

FactoryBot.define do
  factory :octokit, class: OpenStruct do
    skip_create

    node_id     { FFaker::Lorem.characters(40) }

    trait :user do
      name        { FFaker::Name.name }
      login       { FFaker::Internet.user_name }
      email       { FFaker::Internet.email }
      avatar_url  { FFaker::Internet.http_url }
      followers   { FFaker::Number.number(digits: 3) }
      following   { FFaker::Number.number(digits: 3) }
      company     { FFaker::Company.name }
      location    { FFaker::Address.city }
    end

    trait :repo do
      name        { FFaker::Lorem.word.downcase }
      owner_name  { FFaker::Internet.user_name }
      full_name   { "#{owner_name}/#{name}" }
    end
  end

  trait :recently_visited do
    visited_at { Traceable::RECENCY_PERIOD.ago + Traceable::RECENCY_PERIOD / 2 }
  end
end
