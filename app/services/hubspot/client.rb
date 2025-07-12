require 'net/http'
require 'uri'
require 'json'

module Hubspot
  class Client
    BASE_URL = 'https://api.hubapi.com'.freeze

    def initialize(user)
      @user = user
    end

    def associated_contact_id(note_id)
      url = URI("#{BASE_URL}/crm/v3/objects/notes/#{note_id}/associations/contacts")

      headers = {
        'Authorization' => "Bearer #{@user.hubspot_access_token}",
        'Content-Type' => 'application/json'
      }

      res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        http.get(url.request_uri, headers)
      end

      return nil unless res.is_a?(Net::HTTPSuccess)

      parsed = JSON.parse(res.body)
      parsed.dig('results', 0, 'id') # returns first associated contact_id, if present
    end

    def sync_notes!
      ensure_valid_token!
      notes = fetch_all_notes

      notes.each do |note|
        props = note['properties'] || {}

        # Find the associated contact ID via API
        contact_id = associated_contact_id(note['id'])

        unless contact_id
          puts "⚠️ No contact association found for note #{note['id']}. Skipping."
          next
        end

        contact = @user.contacts.find_by(hubspot_id: contact_id)
        unless contact
          puts "⚠️ No local contact found for HubSpot contact ID #{contact_id}. Skipping note #{note['id']}."
          next
        end

        plain_body = Nokogiri::HTML(props['hs_note_body']).text.strip

        ContactNote.find_or_initialize_by(hubspot_id: note['id'], user_id: @user.id).tap do |local_note|
          local_note.contact = contact
          local_note.body = plain_body
          local_note.created_at_hubspot = note['createdAt']
          local_note.updated_at_hubspot = note['updatedAt']
          local_note.save!
        end
      end
    end

    private

    def ensure_valid_token!
      @user.ensure_valid_hubspot_token! if @user.hubspot_token_expires_at.past?
    end

    def fetch_all_notes
      all_notes = []
      after = nil

      loop do
        uri = URI("#{BASE_URL}/crm/v3/objects/notes?limit=100&properties=hs_note_body")
        uri.query += "&after=#{after}" if after

        headers = {
          'Authorization' => "Bearer #{@user.hubspot_access_token}",
          'Content-Type' => 'application/json'
        }

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.get(uri.request_uri, headers)
        end

        raise "Failed to fetch notes: #{response.code} - #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        parsed = JSON.parse(response.body)
        Rails.logger.debug "🔍 HubSpot Notes Response: #{parsed.inspect}"

        all_notes.concat(parsed['results'])
        after = parsed.dig('paging', 'next', 'after')
        break unless after
      end

      all_notes
    end
  end
end
