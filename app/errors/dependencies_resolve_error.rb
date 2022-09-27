# frozen_string_literal: true

class DependenciesResolveError < ProjectError
  def initialize(language)
    super("Unable to resolve project dependencies for language: #{language}")
  end
end
