# frozen_string_literal: true

class Library < ApplicationRecord
  belongs_to :repository

  class << self
    def build(dependency)
      Library.new(name: dependency.name, version: dependency.version, manager: dependency.package_manager)
    end
  end

  def assign(attrs)
    attrs.each { |k, v| self[k] = v }
    self
  end
end
