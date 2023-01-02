# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[github]

  class << self
    def from_github(auth)
      user = User.find_by(provider: auth.provider, uid: auth.uid)
      return user if user

      PriorityUserSurferJob.perform_async(auth.info.nickname, { 'token' => auth.credentials.token })

      User.create(provider: auth.provider, uid: auth.uid) do |created|
        created.username = auth.info.nickname
        created.email = auth.info.email
        created.password = Devise.friendly_token[0, 20]
      end
    end
  end
end
