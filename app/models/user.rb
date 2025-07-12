require 'net/http'
require 'uri'
require 'json'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  def self.from_google(auth)
    user = find_or_initialize_by(email: auth.info.email)

    user.assign_attributes(
      name: auth.info.name,
      provider: auth.provider,
      uid: auth.uid,
      google_token: auth.credentials.token,
      google_refresh_token: auth.credentials.refresh_token || user.google_refresh_token,
      token_expires_at: Time.at(auth.credentials.expires_at)
    )

    # Set a random password if it's a new user (OAuth)
    user.password = SecureRandom.hex(15) if user.encrypted_password.blank?

    user.save!
    user
  end

    def hubspot_token_expired?
    hubspot_token_expires_at.nil? || Time.current >= hubspot_token_expires_at
  end

  
  def refresh_hubspot_token!
    return unless hubspot_refresh_token.present?

    uri = URI('https://api.hubapi.com/oauth/v1/token')
    response = Net::HTTP.post_form(uri, {
      grant_type: 'refresh_token',
      client_id: ENV.fetch('HUBSPOT_CLIENT_ID', nil),
      client_secret: ENV.fetch('HUBSPOT_CLIENT_SECRET', nil),
      refresh_token: hubspot_refresh_token
    })

    json = JSON.parse(response.body)

    if json['access_token']
      update!(
        hubspot_access_token: json['access_token'],
        hubspot_refresh_token: json['refresh_token'] || hubspot_refresh_token,
        hubspot_token_expires_at: Time.current + json['expires_in'].to_i.seconds
      )
    else
      Rails.logger.error("HubSpot token refresh failed: #{json}")
      false
    end
  end

  
  def ensure_valid_hubspot_token!
    refresh_hubspot_token! if hubspot_token_expired?
  end

end
