# frozen_string_literal: true

require_relative "version"
require "json"
require "faraday"
require "faraday_middleware"
require "active_support/core_ext/hash"

module NIEBE
  class Error < StandardError; end

  TOKEN_ENDPOINT = "/oauth/token"

  class Client
    def initialize(client_id: nil, client_secret: nil, verbose: false)
      @client_id = client_id
      @client_secret = client_secret
      @verbose = verbose

      load_json_configuration
    end

    def systems = perform_get("/api/v1/systems").body

    private

    def perform_get(url)
      retries ||= 0
      connection.get(url)
    rescue Faraday::UnauthorizedError => e
      raise e if (retries += 1) > 3

      refresh_access_token
      retry
    end

    def connection
      @connection ||= Faraday.new(url: "https://api.nibeuplink.com") do |conn|
        conn.adapter Faraday.default_adapter
        conn.request :json
        conn.request :oauth2, @access_token, token_type: "bearer"
        conn.response :json, content_type: /\bjson$/
        conn.response :follow_redirects
        conn.request :retry,
                     {
                       max: 2,
                       interval: 0.5,
                       backoff_factor: 2,
                       retry_statuses: [408, 409, 500, 501, 502, 503],
                       methods: %i[get put post head options]
                     }
        conn.response :raise_error
      end
    end

    def load_json_configuration
      token_file_name = "#{Dir.pwd}/.nibe-tokens.json"
      @tokens = JSON.parse(File.read(token_file_name))

      @access_token = @tokens["access_token"]
      @refresh_token = @tokens["refresh_token"]
    end

    def refresh_access_token
      query = {
        grant_type: "refresh_token",
        client_id: @client_id,
        client_secret: @client_secret,
        refresh_token: @refresh_token,
      }.to_query
      result = connection.post(TOKEN_ENDPOINT, query, { "Content-Type" => "application/x-www-form-urlencoded" })
      @connection = nil

      @access_token = result.body["access_token"]
      @refresh_token = result.body["refresh_token"]
    end

    def refresh_token
      @tokens["refresh_token"]
    end

  end
end
