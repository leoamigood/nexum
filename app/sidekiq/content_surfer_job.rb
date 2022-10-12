# frozen_string_literal: true

class ContentSurferJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Job
  include OctokitResource
  include Tracer
  prepend JobBenchmarker
  prepend JobWatcher

  sidekiq_options queue: :high, retry: 3

  sidekiq_throttle(concurrency: { limit: ->(_) { RateLimiter.limited?(get_sidekiq_options['queue']) ? 0 : 2 } })

  def perform(repo_full_name)
    repository = Repository.find_by!(full_name: repo_full_name)
    dependencies = resolve_dependencies(repository)

    libraries = dependencies.map do |dependency|
      library = Library.build(dependency)
      library.repository = repository
      library
    end
    Library.insert_all(libraries.map(&:attributes)) if libraries.present?
  rescue ProjectError => e
    trace(:warning, repository.full_name, message: e.message, value: repository.language)
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
    rescue ProjectError, Dependabot::DependabotError => e
      trace(:warning, repository.full_name, message: e.message, value: repository.language)
      []
    end
  end

  def resolve_processors(repository)
    case repository.language
    when 'Ruby'
      [[Dependabot::Bundler::FileFetcher, Dependabot::Bundler::FileParser]]
    when 'Python'
      [[Dependabot::Python::FileFetcher, Dependabot::Python::FileParser]]
    when 'JavaScript'
      [[Dependabot::NpmAndYarn::FileFetcher, Dependabot::NpmAndYarn::FileParser]]
    when 'Go'
      [[Dependabot::GoModules::FileFetcher, Dependabot::GoModules::FileParser]]
    when 'Java'
      [
        [Dependabot::Gradle::FileFetcher, Dependabot::Gradle::FileParser],
        [Dependabot::Maven::FileFetcher, Dependabot::Maven::FileParser]
      ]
    when 'C#'
      [[Dependabot::Nuget::FileFetcher, Dependabot::Nuget::FileParser]]
    when 'Elixir'
      [[Dependabot::Hex::FileFetcher, Dependabot::Hex::FileParser]]
    when 'PHP'
      [[Dependabot::Composer::FileFetcher, Dependabot::Composer::FileParser]]
    when 'Rust'
      [[Dependabot::Cargo::FileFetcher, Dependabot::Cargo::FileParser]]
    when 'Elm'
      [[Dependabot::Elm::FileFetcher, Dependabot::Elm::FileParser]]
    else
      raise DependenciesResolveError, repository.language
    end
  end

  def resource
    Repository
  end
end
