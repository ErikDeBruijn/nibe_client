#!/usr/bin/env ruby

require_relative "../lib/include.rb"

CREDENTIALS_FILE = ".nibe-credentials.json"

client_id, client_secret = get_client()
nibe_client = NibeUplink::Client.new(verbose: true, client_id: client_id, client_secret: client_secret)
nibe_client_authorize_url = nibe_client.authorize_url(redirect_uri: redirect_uri)
puts "==========================================="
puts "👋 Go to this url and authorize the app: #{nibe_client_authorize_url}"
puts "==========================================="
`open '#{nibe_client_authorize_url}'`

oauth2_authorize(nibe_client)
