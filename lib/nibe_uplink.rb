require "json"
require "faraday"
require "faraday_middleware"
require "active_support/all"

require_relative "nibe_uplink/version"
require_relative "nibe_uplink/client"
require_relative "nibe_uplink/credentials"
require_relative "nibe_uplink/system"

module NibeUplink
  class TokenRefreshError < StandardError; end
  class TokenFileError < StandardError; end
end

Time.zone_default = Time.find_zone!("UTC") if Time.zone.nil?
