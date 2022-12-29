# frozen_string_literal: true

module NibeUplink
  class Client
    TOKEN_ENDPOINT = "/oauth/token"

    attr_reader :token_file

    def initialize(client_id: nil, client_secret: nil, access_token: nil, refresh_token: nil, verbose: false, token_file: nil)
      @client_id = client_id
      @client_secret = client_secret
      @access_token = access_token
      @refresh_token = refresh_token
      @verbose = verbose
      @token_file = token_file
      @token_was_updated = false

      load_token(@token_file) if @token_file
    end

    def systems = perform_get("/api/v1/systems").body

    def token_file_data
      return nil if @token_was_updated == false

      JSON.parse(File.read(@token_file))
          .merge("access_token" => @access_token, "refresh_token" => @refresh_token).to_json
    end

    private

    def perform_get(url)
      retries ||= 0
      connection.get(url)
    rescue Faraday::UnauthorizedError => e
      raise TokenRefreshError, "Couldn't refresh token, retries exhausted #{retries}: #{e}" if (retries += 1) >= 2

      refresh_access_token
      retry
    end

    def connection
      @connection ||= Faraday.new(url: "https://api.nibeuplink.com") do |conn|
        conn.adapter Faraday.default_adapter
        conn.request :json
        conn.request :oauth2, @access_token, token_type: "bearer"
        conn.request :retry,
                     {
                       max: 2,
                       interval: 0.5,
                       backoff_factor: 2,
                       retry_statuses: [408, 409, 500, 501, 502, 503],
                       methods: %i[get put post head options]
                     }
        conn.response :json
        conn.response :follow_redirects
        conn.response :raise_error
      end
    end

    def load_token(file_name = "#{Dir.pwd}/.nibe-tokens.json")
      @tokens = JSON.parse(File.read(file_name))

      @access_token = @tokens["access_token"]
      @refresh_token = @tokens["refresh_token"]
    end

    def refresh_access_token
      query = {
        grant_type: "refresh_token",
        client_id: @client_id,
        client_secret: @client_secret,
        refresh_token: @refresh_token
      }.to_query
      body = connection.post(TOKEN_ENDPOINT, query, { "Content-Type" => "application/x-www-form-urlencoded" }).body
      @connection = nil

      raise TokenRefreshError, "Couldn't refresh the token." if body["access_token"].nil?

      @access_token = body["access_token"]
      @refresh_token = body["refresh_token"]
      @token_was_updated = true
    end
  end
end