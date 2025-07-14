require 'uri'
require 'net/http'
require 'json'

class HubspotController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:callback]

  # Step 1: Start OAuth flow
  def connect
    state = SecureRandom.hex(20)
    session[:hubspot_oauth_state] = state
    session[:hubspot_oauth_user_id] = current_user.id

    redirect_to "https://app.hubspot.com/oauth/authorize" \
                "?client_id=#{ENV.fetch('HUBSPOT_CLIENT_ID')}" \
                "&redirect_uri=#{ENV.fetch('HUBSPOT_REDIRECT_URI')}" \
                "&scope=#{CGI.escape(ENV.fetch('HUBSPOT_SCOPES'))}" \
                "&state=#{state}",
                allow_other_host: true
  end

  # Step 2: OAuth callback
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

  # Fetch contacts from HubSpot
  def contacts
    client = Hubspot::Client.new(current_user)
    @contacts = client.contacts
    Rails.logger.debug "Fetched HubSpot contacts: #{@contacts.inspect}"
  rescue StandardError => e
    Rails.logger.error "HubSpot contacts fetch failed: #{e.message}"
    redirect_to home_index_path, alert: 'Unable to fetch HubSpot contacts.'
  end

  # Sync contacts to local database
  def sync_contacts
    client = Hubspot::Client.new(current_user)
    contacts_data = client.contacts

    contacts_data.each do |data|
      contact = current_user.contacts.find_or_initialize_by(hubspot_id: data['id'])
      properties = data['properties']

      contact.assign_attributes(
        first_name: properties['firstname'],
        last_name: properties['lastname'],
        email: properties['email'],
        created_at_hubspot: data['createdAt'],
        updated_at_hubspot: data['updatedAt']
      )

      contact.save!
    end

    redirect_to contacts_path, notice: 'HubSpot contacts synced successfully.'
  rescue StandardError => e
    Rails.logger.error "HubSpot sync failed: #{e.message}"
    redirect_to home_index_path, alert: 'Failed to sync contacts from HubSpot.'
  end

  private

  # Exchange code for access/refresh tokens
  def exchange_code_for_tokens(code)
    uri = URI('https://api.hubapi.com/oauth/v1/token')

    res = Net::HTTP.post_form(uri, {
      grant_type: 'authorization_code',
      client_id: ENV.fetch('HUBSPOT_CLIENT_ID'),
      client_secret: ENV.fetch('HUBSPOT_CLIENT_SECRET'),
      redirect_uri: ENV.fetch('HUBSPOT_REDIRECT_URI'),
      code: code
    })

    JSON.parse(res.body)
  end

  # Restore user from session (instead of cache)
  def fetch_user_from_state(state)
    return nil unless session[:hubspot_oauth_state] == state

    user_id = session.delete(:hubspot_oauth_user_id)
    session.delete(:hubspot_oauth_state)

    User.find_by(id: user_id)
  end

  # Handle expired or invalid state token
  def handle_invalid_state
    Rails.logger.warn "Invalid or expired HubSpot state token: #{params[:state]}"
    redirect_to new_user_session_path, alert: 'Session expired. Please try connecting again.'
  end

  # Complete token exchange and update user
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

  # Persist HubSpot tokens to user
  def update_user_tokens(user, response)
    user.update!(
      hubspot_access_token: response['access_token'],
      hubspot_refresh_token: response['refresh_token'],
      hubspot_token_expires_at: Time.current + response['expires_in'].to_i.seconds
    )
  end
end
