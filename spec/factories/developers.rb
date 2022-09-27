# frozen_string_literal: true

FactoryBot.define do
  factory :developer do
    name { FFaker::Name.name }
    username { FFaker::Internet.user_name }
    email { FFaker::Internet.email }
    avatar_url { FFaker::Internet.http_url }
    followers_count { FFaker::Number.number(digits: 3) }
    following_count { FFaker::Number.number(digits: 3) }
    company { FFaker::Company.name }
    location { FFaker::Address.city }
    node_id { FFaker::Lorem.characters(40) }
  end
end
