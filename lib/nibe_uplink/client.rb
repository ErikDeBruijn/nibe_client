# frozen_string_literal: true

module NibeUplink
  class Client
    API_BASE_URL = "https://api.nibeuplink.com"
    TOKEN_ENDPOINT = "/oauth/token"
    OAUTH2_ENDPOINT = "/oauth/authorize"

    attr_reader :token_file
    attr_accessor :credentials

    def initialize(client_id: nil, client_secret: nil, access_token: nil, refresh_token: nil, verbose: false, token_file: nil)
      @credentials = Credentials.new(access_token, Time.zone.now, refresh_token)
      @client_id = client_id
      @client_secret = client_secret
      @verbose = verbose
      @token_file = token_file
      @token_was_updated = false
    end

    def systems = perform_get("/api/v1/systems").body

    def token_file_data
      return nil if @token_was_updated == false
      raise TokenFileError, "Token file not set" if @token_file.nil?

      file = File.read(@token_file)
      JSON.parse(file)
          .merge("access_token" => @credentials.access_token, "refresh_token" => @credentials.refresh_token).to_json
    end

    def authorize_url(redirect_uri:)
      query = {
        response_type: "code",
        client_id: @client_id,
        scope: "READSYSTEM", # "READSYSTEM WRITESYSTEM"
        redirect_uri: redirect_uri,
        state: ('a'..'z').to_a.sample(32).join
      }.to_query
      "#{API_BASE_URL}#{OAUTH2_ENDPOINT}?#{query}"
    end

    def get_credentials(code:, state:, redirect_uri:)
      query = {
        code: code,
        grant_type: "authorization_code",
        client_id: @client_id,
        client_secret: @client_secret,
        redirect_uri: CGI.escape(redirect_uri),
        scopes: "READSYSTEM"
      }.map { |k, v| "#{k}=#{v}" }.join("&")

      body = connection.post(
        "#{API_BASE_URL}#{TOKEN_ENDPOINT}",
        query,
        { "Content-Type" => "application/x-www-form-urlencoded" }).body

      @credentials = Credentials.new(
        body["access_token"],
        Time.zone.now + body["expires_in"].to_f,
        body["refresh_token"]
      )
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
        conn.request :oauth2, @credentials.access_token, token_type: "bearer"
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

    def refresh_access_token
      query = {
        grant_type: "refresh_token",
        client_id: @client_id,
        client_secret: @client_secret,
        refresh_token: @credentials.refresh_token
      }.to_query

      conn = Faraday.new(url: "https://api.nibeuplink.com") do |conn|
        conn.request :url_encoded
        conn.response :json
      end

      body = conn.post(TOKEN_ENDPOINT, query).body
      @connection = nil

      raise TokenRefreshError, "Couldn't refresh the token. #{body} #{query}" if body["access_token"].nil?

      @credentials = Credentials.new(
        body["access_token"],
        Time.zone.now + body["expires_in"].to_f,
        body["refresh_token"]
      )

      @token_was_updated = true
    end
  end
end