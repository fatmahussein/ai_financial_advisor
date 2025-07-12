require 'uri'
require 'net/http'
require 'json'

class HubspotController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:callback]

  def connect
    state = SecureRandom.hex(20)
    Rails.cache.write("hubspot_oauth_#{state}", current_user.id, expires_in: 10.minutes)

    redirect_to 'https://app.hubspot.com/oauth/authorize' \
                "?client_id=#{ENV.fetch('HUBSPOT_CLIENT_ID', nil)}" \
                "&redirect_uri=#{ENV.fetch('HUBSPOT_REDIRECT_URI', nil)}" \
                "&scope=#{CGI.escape(ENV.fetch('HUBSPOT_SCOPES', nil))}" \
                "&state=#{state}",
                allow_other_host: true
  end

  def callback
    Rails.logger.debug "HubSpot callback params: #{params.inspect}"

    @user = fetch_user_from_state(params[:state])
    return handle_invalid_state unless @user

    if params[:code].present?
      process_token_exchange(params[:code])
    else
      Rails.logger.warn 'No code param found in HubSpot callback'
      redirect_to home_index_path, alert: 'Authorization code missing.'
    end
  end

  private

  def exchange_code_for_tokens(code)
    uri = URI('https://api.hubapi.com/oauth/v1/token')

    res = Net::HTTP.post_form(uri, {
                                grant_type: 'authorization_code',
                                client_id: ENV.fetch('HUBSPOT_CLIENT_ID', nil),
                                client_secret: ENV.fetch('HUBSPOT_CLIENT_SECRET', nil),
                                redirect_uri: ENV.fetch('HUBSPOT_REDIRECT_URI', nil),
                                code: code
                              })

    JSON.parse(res.body)
  end

  def fetch_user_from_state(state)
    user_id = Rails.cache.read("hubspot_oauth_#{state}")
    Rails.cache.delete("hubspot_oauth_#{state}")
    User.find_by(id: user_id)
  end

  def handle_invalid_state
    Rails.logger.warn "Invalid or expired HubSpot state token: #{params[:state]}"
    redirect_to new_user_session_path, alert: 'Session expired. Please try connecting again.'
  end

  def process_token_exchange(code)
    response = exchange_code_for_tokens(code)
    Rails.logger.debug "HubSpot token exchange response: #{response.inspect}"

    if response['access_token']
      update_user_tokens(@user, response)
      Rails.logger.info "HubSpot connected successfully for user #{@user.email}"
      sign_in(@user) unless current_user == @user
      redirect_to home_index_path, notice: 'HubSpot connected successfully!'
    else
      Rails.logger.error "Failed to retrieve HubSpot tokens: #{response.inspect}"
      redirect_to home_index_path, alert: 'Failed to connect with HubSpot.'
    end
  end

  def update_user_tokens(user, response)
    user.update!(
      hubspot_access_token: response['access_token'],
      hubspot_refresh_token: response['refresh_token'],
      hubspot_token_expires_at: Time.current + response['expires_in'].to_i.seconds
    )
  end
end
