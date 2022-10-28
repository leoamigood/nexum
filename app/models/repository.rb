# frozen_string_literal: true

class Repository < ApplicationRecord
  include Traceable

  belongs_to :developer

  after_initialize :sanitize

  class << self
    def build(repo)
      Repository.new(repo.attrs.select { |attr| column_names.include?(attr.to_s) })
    end

    def recently_visited?(full_name)
      recent.where(full_name:).present?
    end
  end

  def sanitize
    SanitationUtils.sanitize_model(self)
    self
  end

  def assign(attrs)
    attrs.each { |k, v| self[k] = v }
    self
  end
end
