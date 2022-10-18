# frozen_string_literal: true

module Enum
  class Language
    include Ruby::Enum

    define :RUBY,         'Ruby'
    define :PYTHON,       'Python'
    define :JAVASCRIPT,   'JavaScript'
    define :GO,           'Go'
    define :JAVA,         'Java'
    define :C_SHARP,      'C#'
    define :ELIXIR,       'Elixir'
    define :PHP,          'PHP'
    define :RUST,         'Rust'
    define :ELM,          'Elm'
  end
end
