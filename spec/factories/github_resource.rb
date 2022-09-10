# frozen_string_literal: true

FactoryBot.define do
  factory :github_resource, class: OpenStruct do
    node_id     { FFaker::Lorem.characters(40) }
  end

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
end
