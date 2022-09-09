# frozen_string_literal: true

FactoryBot.define do
  factory :user_resource do
    node_id     { FFaker::Lorem.characters(40) }
    login       { FFaker::Internet.user_name }
    avatar_url  { FFaker::Internet.http_url }
    followers   { FFaker::Number.number(digits: 3) }
    name        { FFaker::Name.name }
    company     { FFaker::Company.name }
    location    { FFaker::Address.city }
    email       { FFaker::Internet.email }
  end
end
