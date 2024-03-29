# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq/cron/web'
require 'sidekiq_unique_jobs/web'

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations', omniauth_callbacks: 'omniauth_callbacks' }
  mount Sidekiq::Web, at: '/sidekiq'

  scope :monitoring do
    # Sidekiq Basic Auth from routes on production environment
    if Rails.env.production?
      Sidekiq::Web.use Rack::Auth::Basic do |username, password|
        ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(username), Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_AUTH_USERNAME'))) &
          ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(password), Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_AUTH_PASSWORD')))
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'charts#index'
  get 'stats', action: 'stats', controller: 'charts'
end
