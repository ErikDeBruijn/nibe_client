# frozen_string_literal: true

# This file is required by bin/authorize.rb and other files that need to use NibeUplink::Client.

BASE_PATH = File.dirname(File.dirname(__FILE__))
$LOAD_PATH.unshift("#{BASE_PATH}/lib")

require 'nibe_uplink'
require 'webrick'

def get_client
  file_name = "#{BASE_PATH}/.nibe-client.json"
  return if !File.exist?(file_name)

  client_id_and_secret = JSON.parse(File.read(file_name))
  client_id = client_id_and_secret["client_id"]
  client_secret = client_id_and_secret["client_secret"]
  [client_id, client_secret]
end

def ask_for_client_details
  puts "Please enter your client_id:"
  client_id = gets.chomp
  puts "Please enter your client_secret:"
  client_secret = gets.chomp
  [client_id, client_secret]
end

def redirect_uri = "http://127.0.0.1:8000/oauth/callback"

def oauth2_authorize(nibe_client)
  server = WEBrick::HTTPServer.new(Port: 8000)

  server.mount_proc("/") do |req, res|
    next unless req.path == "/oauth/callback"

    credentials = nibe_client.get_credentials(
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
  file_path = "#{BASE_PATH}/#{CREDENTIALS_FILE}"
  puts "Writing credentials to #{file_path}..."
  File.write(file_path, JSON.pretty_generate({
                                               access_token: credentials.access_token,
                                               refresh_token: credentials.refresh_token
                                             }))
  puts " Done."
  file_path
end
