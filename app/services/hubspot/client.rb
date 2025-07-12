require 'net/http'
require 'uri'
require 'json'

module Hubspot
  class Client
    BASE_URL = 'https://api.hubapi.com'

    def initialize(user)
      @user = user
    end

def contacts
  ensure_valid_token!
  all_contacts = []
  after = nil

  loop do
    url = URI("#{BASE_URL}/crm/v3/objects/contacts?limit=100")
    url.query += "&after=#{after}" if after

    headers = {
      'Authorization' => "Bearer #{@user.hubspot_access_token}",
      'Content-Type' => 'application/json'
    }

    res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
      http.get(url.request_uri, headers)
    end

    raise "HubSpot API error: #{res.code}" unless res.is_a?(Net::HTTPSuccess)

    parsed = JSON.parse(res.body)
    all_contacts.concat(parsed['results'])

    after = parsed.dig('paging', 'next', 'after')
    break unless after
  end

  all_contacts
end


    private

    def ensure_valid_token!
      @user.ensure_valid_hubspot_token! if @user.hubspot_token_expires_at.past?
    end
  end
end
