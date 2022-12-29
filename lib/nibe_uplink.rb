require "json"
require "faraday"
require "faraday_middleware"
require "active_support/core_ext/hash"

require_relative "nibe_uplink/version"
require_relative "nibe_uplink/client"

module NibeUplink
  class TokenRefreshError < StandardError; end
end