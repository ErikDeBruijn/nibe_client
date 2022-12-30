#!/usr/bin/env ruby

require_relative "../lib/include.rb"

CREDENTIALS_FILE = ".nibe-credentials.json"

client_id, client_secret = get_client()
niebe_client = NibeUplink::Client.new(verbose: true, client_id: client_id, client_secret: client_secret)
niebe_client_authorize_url = niebe_client.authorize_url(redirect_uri: redirect_uri)
puts "==========================================="
puts "👋 Go to this url and authorize the app: #{niebe_client_authorize_url}"
puts "==========================================="
`open '#{niebe_client_authorize_url}'`

oauth2_authorize(niebe_client)

pp result: result
