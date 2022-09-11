# frozen_string_literal: true

module Enum
  class TraceState
    extend Digester
    include Ruby::Enum

    define :ATTEMPTED,    'attempted'
    define :IN_PROGRESS,  'in_progress'
    define :SUCCEEDED,    'succeeded'
    define :SKIPPED,      'skipped'
    define :FAILED,       'failed'

    def self.digest!(value)
      digest_with_error(value, NotAcceptableTraceStateError)
    end
  end
end
