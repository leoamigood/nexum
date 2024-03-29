# frozen_string_literal: true

class ContentSurferJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Job
  include OctokitResource
  include Tracer
  prepend JobBenchmarker
  prepend ResourceJobTracer
  prepend JobWatcher

  sidekiq_options queue: :high, retry: 3, timeout: 15.minutes,
                  lock: :until_executed, on_conflict: { client: :log, server: :reject }

  sidekiq_throttle(concurrency: { limit: ->(*_args) { RateLimiter.limited?(sidekiq_options['queue']) ? 0 : 2 } })

  def perform(repo_full_name)
    repository = Repository.find_by!(full_name: repo_full_name)
    dependencies = resolve_dependencies(repository)

    libraries = dependencies.map do |dependency|
      library = Library.build(dependency)
      library.repository = repository
      library
    end

    if libraries.present?
      Library.transaction do
        Library.where(repository_id: libraries.map(&:repository_id)).delete_all
        Library.insert_all(libraries.map(&:attributes))
      end
    end
  rescue ProjectError => e
    trace(:warning, repository.full_name, message: e.message, value: e.class.name)
  end

  def resolve_dependencies(repository)
    processors = resolve_processors(repository)
    processors.flat_map do |fetcher_class, parser_class|
      filenames = client.contents(repository.full_name).map(&:name)
      raise DependenciesResolveError, fetcher_class.required_files_message unless fetcher_class.required_files_in?(filenames)

      source = Dependabot::Source.new(provider: OctokitClient::PROVIDER_GITHUB, repo: repository.full_name)
      dependency_files = fetcher_class.new(source:, credentials: OctokitClient::GITHUB_CREDENTIALS).files

      source = Dependabot::Source.new(provider: OctokitClient::PROVIDER_GITHUB, repo: repository.full_name)
      parser = parser_class.new(dependency_files:, source:)

      parser.parse
    rescue StandardError, Dependabot::DependabotError => e
      trace(:warning, repository.full_name, message: e.message, value: e.class.name)
      []
    end
  end

  private

  def resolve_processors(repository)
    case repository.language
    when Enum::Language::RUBY
      [[Dependabot::Bundler::FileFetcher, Dependabot::Bundler::FileParser]]
    when Enum::Language::PYTHON
      [[Dependabot::Python::FileFetcher, Dependabot::Python::FileParser]]
    when Enum::Language::JAVASCRIPT
      [[Dependabot::NpmAndYarn::FileFetcher, Dependabot::NpmAndYarn::FileParser]]
    when Enum::Language::GO
      [[Dependabot::GoModules::FileFetcher, Dependabot::GoModules::FileParser]]
    when Enum::Language::JAVA
      [
        [Dependabot::Gradle::FileFetcher, Dependabot::Gradle::FileParser],
        [Dependabot::Maven::FileFetcher, Dependabot::Maven::FileParser]
      ]
    when Enum::Language::C_SHARP
      [[Dependabot::Nuget::FileFetcher, Dependabot::Nuget::FileParser]]
    when Enum::Language::ELIXIR
      [[Dependabot::Hex::FileFetcher, Dependabot::Hex::FileParser]]
    when Enum::Language::PHP
      [[Dependabot::Composer::FileFetcher, Dependabot::Composer::FileParser]]
    when Enum::Language::RUST
      [[Dependabot::Cargo::FileFetcher, Dependabot::Cargo::FileParser]]
    when Enum::Language::ELM
      [[Dependabot::Elm::FileFetcher, Dependabot::Elm::FileParser]]
    else
      raise DependenciesResolveError, repository.language
    end
  end

  def resource
    Repository
  end
end
