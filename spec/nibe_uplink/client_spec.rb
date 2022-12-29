describe NibeUplink::Client do
  let(:client_id_and_secret) { JSON.parse(File.read(".nibe-client.json")) }
  let(:client_id) { client_id_and_secret["client_id"] }
  let(:client_secret) { client_id_and_secret["client_secret"] }

  it "fetches a token from the token endpoint" do
    client = described_class.new(verbose: true, access_token: "expired-token-1234", refresh_token: "refresh-token-1234",
                                 client_id: client_id, client_secret: client_secret)

    stub_request(:get, "https://api.nibeuplink.com/api/v1/systems")
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer expired-token-1234",
          "User-Agent" => "Faraday v1.10.2"
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
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer new-access-token-1234",
          "User-Agent" => "Faraday v1.10.2"
        }
      ).to_return(status: 200, body: { used_new_token: "true" }.to_json, headers: {})
    expect(client.systems).to eq({ "used_new_token" => "true" })
  end

  it "loads a token from a file" do
    client = described_class.new(verbose: true, token_file: "fixtures/token.json")
    stub_request(:get, "https://api.nibeuplink.com/api/v1/systems")
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer access_token-1234",
          "User-Agent" => "Faraday v1.10.2"
        }
      ).to_return(status: 200, body: { test: true }.to_json, headers: {})
    expect(client.systems["test"]).to be_truthy
  end

  it "provides new token data (to update our token file)" do
    client = described_class.new(verbose: true, token_file: "fixtures/token.json",
                                 client_id: client_id, client_secret: client_secret)
    stub_request(:get, "https://api.nibeuplink.com/api/v1/systems")
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer access_token-1234",
          "User-Agent" => "Faraday v1.10.2"
        }
      ).to_return(status: 401, body: "", headers: {})

    stub_request(:post, "https://api.nibeuplink.com/oauth/token").
      with(
        body: { "client_id" => "client-1234", "client_secret" => "client-secret-1234", "grant_type" => "refresh_token", "refresh_token" => "refresh_token-1234" },
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer access_token-1234",
          "Content-Type" => "application/x-www-form-urlencoded",
          "User-Agent" => "Faraday v1.10.2"
        }).to_return(status: 200, body: { access_token: "new-access-token-1234",
                                          refresh_token: "new-refresh-token-1234" }.to_json, headers: {})

    stub_request(:get, "https://api.nibeuplink.com/api/v1/systems")
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer new-access-token-1234",
          "User-Agent" => "Faraday v1.10.2"
        }).to_return(status: 200, body: "", headers: {})

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

  it "has a version number" do
    expect(NibeUplink::VERSION).not_to be_nil
  end
end
