describe "NIEBE::Client" do
  let(:client_id_and_secret) { JSON.parse(File.read(".nibe-client.json")) }
  let(:client_id) { client_id_and_secret["client_id"] }
  let(:client_secret) { client_id_and_secret["client_secret"] }

  it "fetches a token from the token endpoint" do
    client = NIEBE::Client.new(verbose: true, client_id: client_id, client_secret: client_secret)
    pp client.systems
  end

  it "has a version number" do
    expect(NIEBE::VERSION).not_to be_nil
  end
end
