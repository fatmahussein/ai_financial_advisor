require 'google/apis/gmail_v1'
require 'googleauth'

class GmailService
  GMAIL = Google::Apis::GmailV1
  SCOPE = [
    'https://www.googleapis.com/auth/gmail.readonly'
  ]

  def initialize(user)
    @user = user
    @service = GMAIL::GmailService.new
    @service.authorization = authorize
  end

  def fetch_and_store_messages
    result = @service.list_user_messages('me', max_results: 50)
    return unless result.messages

    result.messages.each do |msg|
      full_message = @service.get_user_message('me', msg.id)
      next if Email.exists?(gmail_id: full_message.id, user: @user)

      payload = full_message.payload
      headers = payload.headers.each_with_object({}) do |h, memo|
        memo[h.name.downcase] = h.value
      end

      Email.create!(
        user: @user,
        gmail_id: full_message.id,
        subject: headers['subject'],
        sender: headers['from'],
        snippet: full_message.snippet,
        received_at: Time.at(full_message.internal_date.to_i / 1000),
        body: extract_body(payload)
      )
    end
  end

  private

  def authorize
    Signet::OAuth2::Client.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      access_token: @user.google_token,
      refresh_token: @user.google_refresh_token,
      token_credential_uri: 'https://oauth2.googleapis.com/token'
    )
  end

    def extract_body(payload)
    parts = payload.parts || [payload]

    parts.map do |part|
        next unless part.mime_type == 'text/plain' && part.body&.data

        begin
        Base64.urlsafe_decode64(part.body.data).force_encoding('UTF-8')
        rescue ArgumentError => e
        Rails.logger.warn "Skipping invalid base64 body: #{e.message}"
        nil
        end
    end.compact.join("\n")
    end

end
