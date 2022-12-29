module NibeUplink
  class Credentials
    attr_accessor :access_token, :expires_at, :refresh_token

    def initialize(access_token, expires_at, refresh_token)
      @access_token = access_token
      @expires_at = expires_at
      @refresh_token = refresh_token
    end

    def self.load_from_file(file)
      data = JSON.parse(File.read(file))
      new(data["access_token"], Time.zone.now + data["expires_in"].to_f, data["refresh_token"])
    end
  end
end
