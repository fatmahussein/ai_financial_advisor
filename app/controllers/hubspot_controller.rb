require 'uri'
require 'net/http'
require 'json'

class HubspotController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:callback]

 def connect
state = SecureRandom.hex(20)
Rails.cache.write("hubspot_oauth_#{state}", current_user.id, expires_in: 10.minutes)

redirect_to "https://app.hubspot.com/oauth/authorize" \
            "?client_id=#{ENV['HUBSPOT_CLIENT_ID']}" \
            "&redirect_uri=#{ENV['HUBSPOT_REDIRECT_URI']}" \
            "&scope=#{CGI.escape(ENV['HUBSPOT_SCOPES'])}" \
            "&state=#{state}",
            allow_other_host: true
end

 
def callback
  Rails.logger.debug "HubSpot callback params: #{params.inspect}"

  user_id = Rails.cache.read("hubspot_oauth_#{params[:state]}")
  user = User.find_by(id: user_id)

  if user_id.nil? || user.nil?
    Rails.logger.warn "Invalid or expired HubSpot state token: #{params[:state]}"
    redirect_to new_user_session_path, alert: "Session expired. Please try connecting again."
    return
  end

  Rails.cache.delete("hubspot_oauth_#{params[:state]}")

  if params[:code].present?
    response = exchange_code_for_tokens(params[:code])
    Rails.logger.debug "HubSpot token exchange response: #{response.inspect}"

    if response['access_token']
      user.update!(
        hubspot_access_token: response['access_token'],
        hubspot_refresh_token: response['refresh_token'],
        hubspot_token_expires_at: Time.current + response['expires_in'].to_i.seconds
      )

      Rails.logger.info "HubSpot connected successfully for user #{user.email}"
      sign_in(user) unless current_user == user
      redirect_to home_index_path, notice: "HubSpot connected successfully!"
    else
      Rails.logger.error "Failed to retrieve HubSpot tokens: #{response.inspect}"
      redirect_to home_index_path, alert: "Failed to connect with HubSpot."
    end
  else
    Rails.logger.warn "No code param found in HubSpot callback"
    redirect_to home_index_path, alert: "Authorization code missing."
  end
end



  private
    def exchange_code_for_tokens(code)
    uri = URI("https://api.hubapi.com/oauth/v1/token")

    res = Net::HTTP.post_form(uri, {
      grant_type: "authorization_code",
      client_id: ENV['HUBSPOT_CLIENT_ID'],
      client_secret: ENV['HUBSPOT_CLIENT_SECRET'],
      redirect_uri: ENV['HUBSPOT_REDIRECT_URI'],
      code: code
    })

    JSON.parse(res.body)
  end

end
