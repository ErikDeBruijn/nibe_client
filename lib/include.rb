# frozen_string_literal: true

# This file is required by bin/authorize.rb and other files that need to use NibeUplink::Client.

$LOAD_PATH.unshift('../lib')


require 'nibe_uplink'
require 'webrick'

Time.zone_default = Time.find_zone!("UTC")

def get_client
  client_id_and_secret = JSON.parse(File.read("#{File.dirname(Dir.pwd)}/.nibe-client.json"))
  client_id = client_id_and_secret["client_id"]
  client_secret = client_id_and_secret["client_secret"]
  [client_id, client_secret]
end

def redirect_uri = "http://127.0.0.1:8000/oauth/callback"

def oauth2_authorize(niebe_client)
  server = WEBrick::HTTPServer.new(Port: 8000)

  server.mount_proc("/") do |req, res|
    next unless req.path == "/oauth/callback"

    credentials = niebe_client.get_credentials(
      code: req.query["code"],
      state: req.query["state"],
      redirect_uri: redirect_uri
    )
    server.stop
    store_credentials(credentials)
    res.body << "<h1>Credentials are now stored!</h1>"
    res.body << "<p>Location: <pre>#{CREDENTIALS_FILE}</pre><br>You can close this window now!</p>"
  end

  trap("INT") { server.shutdown }
  server.start
end

def store_credentials(credentials)
  file_path = "#{File.dirname(Dir.pwd)}/#{CREDENTIALS_FILE}"
  puts "Writing credentials to #{file_path}..."
  File.write(file_path, JSON.pretty_generate({
                                               access_token: credentials.access_token,
                                               refresh_token: credentials.refresh_token
                                             }))
  puts " Done."
  file_path
end
