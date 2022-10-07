# frozen_string_literal: true

gem "bundler", "~> 2.3"
require "bundler/setup"
require "json"

$LOAD_PATH.unshift(File.expand_path("./lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("./monkey_patches", __dir__))

trap "HUP" do
  puts JSON.generate(error: "timeout", error_class: "Timeout::Error", trace: [])
  exit 2
end

# Bundler monkey patches
require "definition_ruby_version_patch"
require "definition_bundler_version_patch"
require "endpoint_specification_patch"
require "git_source_patch"

require "functions"

MIN_BUNDLER_VERSION = "2.1.0"

def validate_bundler_version!
  return true if correct_bundler_version?

  raise StandardError, "Called with Bundler '#{Bundler::VERSION}', expected >= '#{MIN_BUNDLER_VERSION}'"
end

def correct_bundler_version?
  Gem::Version.new(Bundler::VERSION) >= Gem::Version.new(MIN_BUNDLER_VERSION)
end

def output(obj)
  print JSON.dump(obj)
end

begin
  validate_bundler_version!

  request = JSON.parse($stdin.read)

  function = request["function"]
  args = request["args"].transform_keys(&:to_sym)

  output({ result: Functions.send(function, **args) })
rescue StandardError => e
  output(
    { error: e.message, error_class: e.class, trace: e.backtrace }
  )
  exit(1)
end