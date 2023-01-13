# frozen_string_literal: true

module OctokitToken
  def perform(*args)
    @token = args.last['token'] if args.last.is_a?(Hash)

    super(*args)
  end

  def token
    @token
  end
end
