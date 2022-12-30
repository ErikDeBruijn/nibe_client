describe NibeUplink::Client do
  let(:client_id_and_secret) { JSON.parse(File.read(".nibe-client.json")) }
  let(:client_id) { client_id_and_secret["client_id"] }
  let(:client_secret) { client_id_and_secret["client_secret"] }

  it "fetches a token from the token endpoint" do
    client = described_class.new(verbose: true, access_token: "expired-token-1234", refresh_token: "refresh-token-1234",
                                 client_id: "client-1234", client_secret: "client-secret-1234")

    stub_request(:get, "https://api.nibeuplink.com/api/v1/systems")
      .with(
        headers: {
          "Authorization" => "Bearer expired-token-1234",
        }
      ).to_return(status: 401, body: "", headers: {})

    stub_request(:post, "https://api.nibeuplink.com/oauth/token")
      .with(
        body: {
          "client_id" => "client-1234",
          "client_secret" => "client-secret-1234",
          "grant_type" => "refresh_token",
          "refresh_token" => "refresh-token-1234"
        }
      ).to_return(status: 200, body: { access_token: "new-access-token-1234",
                                       refresh_token: "new-refresh-token-1234" }.to_json, headers: {})

    stub_request(:get, "https://api.nibeuplink.com/api/v1/systems")
      .with(
        headers: {
          "Authorization" => "Bearer new-access-token-1234",
        }
      ).to_return(status: 200, body: { used_new_token: "true" }.to_json, headers: {})
    expect(client.systems).to eq({ "used_new_token" => "true" })
  end

  it "loads a token from a file" do
    client = described_class.new(verbose: true)
    client.credentials = NibeUplink::Credentials.load_from_file("fixtures/token.json")
    stub_request(:get, "https://api.nibeuplink.com/api/v1/systems")
      .with(
        headers: {
          "Authorization" => "Bearer access_token-1234",
        }
      ).to_return(status: 200, body: { test: true }.to_json, headers: {})
    expect(client.systems["test"]).to be_truthy
  end

  it "provides new token data (to update our token file)" do
    client = described_class.new(verbose: true, token_file: "fixtures/token.json",
                                 client_id: "client-1234", client_secret: "client-secret-1234")
    client.credentials = NibeUplink::Credentials.load_from_file("#{Dir.pwd}/fixtures/token.json")
    stub_request(:get, "https://api.nibeuplink.com/api/v1/systems")
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "User-Agent" => "Faraday v1.10.2"
        }
      ).to_return(status: 401, body: "", headers: {})

    stub_request(:post, "https://api.nibeuplink.com/oauth/token")
      .with(
        body: { "client_id" => "client-1234",
                "client_secret" => "client-secret-1234",
                "grant_type" => "refresh_token",
                "refresh_token" => "refresh_token-1234" },
        headers: { "Content-Type" => "application/x-www-form-urlencoded" }
      ).to_return(status: 200, body: { access_token: "new-access-token-1234",
                                       refresh_token: "new-refresh-token-1234" }.to_json, headers: {})

    stub_request(:get, "https://api.nibeuplink.com/api/v1/systems")
      .with(
        headers: { "Authorization" => "Bearer new-access-token-1234" }
      ).to_return(status: 200, body: "", headers: {})

    expect(client.token_file_data).to be_nil
    client.systems
    expect(JSON.parse(client.token_file_data))
      .to include({
                    "access_token" => "new-access-token-1234",
                    "client_id" => "client_id-1234",
                    "client_secret" => "client_secret-1234",
                    "expires_at" => 1_672_312_058,
                    "refresh_token" => "new-refresh-token-1234",
                    "token_type" => "bearer"
                  })
  end

  describe "#authorize_url" do
    it "returns the correct authorization url" do
      client = described_class.new(verbose: true, client_id: client_id)
      auth_url = client.authorize_url(redirect_uri: "http://localhost/oauth2/callback")
      puts auth_url
      expect(auth_url)
        .to start_with("https://api.nibeuplink.com/oauth/authorize?client_id=#{client_id}&redirect_uri=http%3A%2F%2Flocalhost%2Foauth2%2Fcallback&response_type=code&scope=READSYSTEM&state=")
    end
  end

  describe "#get_credentials" do
    it "returns new credentials" do
      expected_token = <<~JSON
        {"access_token":"access-token-1234","token_type":"bearer","expires_in":1800,"refresh_token":"refresh-token-1234","scope":"READSYSTEM"}
      JSON

      stub_request(:post, "https://api.nibeuplink.com/oauth/token")
        .with(
          body: { "client_id" => client_id,
                  "client_secret" => client_secret,
                  "code" => "1234",
                  "grant_type" => "authorization_code",
                  "redirect_uri" => "http://127.0.0.1:8000/oauth/callback",
                  "scopes" => "READSYSTEM" },
          headers: {
            "Content-Type" => "application/x-www-form-urlencoded",
          }
        ).to_return(status: 200, body: expected_token, headers: { "Content-Type" => "application/json" })

      redirect_uri = "http://127.0.0.1:8000/oauth/callback"
      nibe_client = described_class.new(verbose: true, client_id: client_id, client_secret: client_secret)
      credentials = nibe_client.get_credentials(code: "1234", state: "abcd", redirect_uri: redirect_uri)

      expect(credentials).to have_attributes(access_token: "access-token-1234", refresh_token: "refresh-token-1234")
    end

    xit "authorizes and returns the retrieved credentials" do
      # This spec is to be run manually, because it requires user interaction and will call NIBE's APIs.
      # Remove the x to run it.
      WebMock.allow_net_connect!

      redirect_uri = "http://127.0.0.1:8000/oauth/callback"
      nibe_client = described_class.new(verbose: true, client_id: client_id, client_secret: client_secret)

      nibe_client_authorize_url = nibe_client.authorize_url(redirect_uri: redirect_uri)
      puts "Go to this url and authorize the app: #{nibe_client_authorize_url}"
      `open '#{nibe_client_authorize_url}'`

      server = WEBrick::HTTPServer.new(Port: 8000)

      server.mount_proc("/") do |req, res|
        next unless req.path == "/oauth/callback"

        credentials = nibe_client.get_credentials(
          code: req.query["code"],
          state: req.query["state"],
          redirect_uri: redirect_uri
        )
        server.stop
        expect(credentials).to have_attributes(access_token: String, refresh_token: String)
        pp access_token: credentials.access_token, refresh_token: credentials.refresh_token
      end

      trap("INT") { server.shutdown }
      server.start
    end
  end

  describe "#systems" do
    it "returns a list of Systems" do
      fixture = File.read("fixtures/systems.json")

      stub_request(:get, "https://api.nibeuplink.com/api/v1/systems")
        .to_return(status: 200, body: fixture, headers: {})

      client = described_class.new(verbose: true)
      systems = client.systems
      pp systems
      expect(systems.keys).to eq([169_087])
      expect(systems.values.first.product_name).to eq("NIBE F1255")
      expect(systems.values.first.name).to eq("F1255-6 R PC")
      expect(systems.values.first.name).to eq("F1255-6 R PC")
    end
  end

  describe "#system" do
    it "returns a System" do
      fixture = File.read("fixtures/system.json")

      stub_request(:get, "https://api.nibeuplink.com/api/v1/systems/169087")
        .to_return(status: 200, body: fixture, headers: {})

      client = described_class.new(verbose: true)
      system = client.system(169_087)
      pp system
      # expect(system.product_name).to eq("NIBE F1255")
      # expect(system.name).to eq("F1255-6 R PC")
      # expect(system.name).to eq("F1255-6 R PC")
    end
  end

  it "has a version number" do
    expect(NibeUplink::VERSION).not_to be_nil
  end
end
