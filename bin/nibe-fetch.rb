#!/usr/bin/env ruby

require_relative "#{File.dirname(File.dirname(__FILE__))}/lib/include.rb"

def update_token_file(client)
  token_file_data = client.token_file_data
  return unless token_file_data

  File.write(client.token_file, token_file_data)
end

token_file = "#{BASE_PATH}/.nibe-credentials.json"
client_id, client_secret = get_client
nibe_client = NibeUplink::Client.new(token_file: token_file, verbose: true, client_id: client_id, client_secret: client_secret)

nibe_client.credentials = NibeUplink::Credentials.load_from_file(token_file)
systems = nibe_client.systems

puts "Getting data for #{systems.count} systems:"

systems.each do |(system_id, system)|
  puts "#{systems[system_id].name} ID: #{system_id}"
  system_status = system.get_status
  puts system_status.map { |k,v| [k, "#{v[:value]} #{v[:unit]}"]}.to_yaml
  # puts system_status.to_json
end

update_token_file(nibe_client)
