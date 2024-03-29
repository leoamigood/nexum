# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.3', '>= 7.0.3.1'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgres as the database for Active Record
gem 'pg'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem 'chartkick'

gem 'dependabot-common',        github: 'leoamigood/dependabot-core'
gem 'dependabot-bundler',       github: 'leoamigood/dependabot-core'
gem 'dependabot-gradle',        github: 'leoamigood/dependabot-core'
gem 'dependabot-maven',         github: 'leoamigood/dependabot-core'
gem 'dependabot-python',        github: 'leoamigood/dependabot-core'
gem 'dependabot-npm_and_yarn',  github: 'leoamigood/dependabot-core'
gem 'dependabot-go_modules',    github: 'leoamigood/dependabot-core'
gem 'dependabot-hex',           github: 'leoamigood/dependabot-core'
gem 'dependabot-composer',      github: 'leoamigood/dependabot-core'
gem 'dependabot-cargo',         github: 'leoamigood/dependabot-core'
gem 'dependabot-elm',           github: 'leoamigood/dependabot-core'
gem 'dependabot-nuget',         github: 'leoamigood/dependabot-core'

gem 'devise'
gem 'faraday-retry'
gem 'groupdate'
gem 'rack-mini-profiler'
gem 'mime-types-data', '3.2021.1115'
gem 'octokit', '~> 5.0'
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'
gem 'rollbar'
gem 'ruby-enum'
gem 'scenic'
gem 'sidekiq', '~> 6.5'
gem 'sidekiq-cron'
gem 'sidekiq-throttled', github: 'ixti/sidekiq-throttled'
gem 'sidekiq-unique-jobs', '~> 7.0'

gem 'bundler-audit', require: false
gem 'rubocop-performance', require: false
gem 'rubocop-rails', require: false
gem 'rubocop-rspec', require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'brakeman'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'rspec-json_expectations'
  gem 'rspec-rails', '~> 5.1'
  gem 'spring'
end

group :development do
  # For memory profiling
  gem 'memory_profiler'

  # For call-stack profiling flamegraphs
  gem 'stackprof'

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'rspec-sidekiq'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webdrivers'
end
