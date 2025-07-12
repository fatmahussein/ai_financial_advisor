require 'google/apis/gmail_v1'
require 'googleauth'
require 'base64'
require 'mail' 

class GmailService
  GMAIL = Google::Apis::GmailV1
  SCOPE = [
    'https://www.googleapis.com/auth/gmail.readonly'
  ].freeze

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
      client_id: ENV.fetch('GOOGLE_CLIENT_ID', nil),
      client_secret: ENV.fetch('GOOGLE_CLIENT_SECRET', nil),
      access_token: @user.google_token,
      refresh_token: @user.google_refresh_token,
      token_credential_uri: 'https://oauth2.googleapis.com/token'
    )
  end

def extract_body(payload)
  return "" unless payload

  parts = flatten_parts(payload)

  # Prefer plain > html
  part = parts.find { |p| p.mime_type == 'text/plain' } ||
         parts.find { |p| p.mime_type == 'text/html' } ||
         parts.first

  return "" unless part&.body&.data

  encoding = (part.headers || []).find { |h| h.name.downcase == 'content-transfer-encoding' }&.value&.downcase || 'base64'
  raw = part.body.data

  decoded =
    case encoding
    when 'base64'
      Base64.urlsafe_decode64(raw)
    when 'quoted-printable'
      Mail::Encodings::QuotedPrintable.decode(raw)
    else
      raw
    end

  decoded = decoded.force_encoding("UTF-8").scrub


  # Clean HTML if no plain text
  decoded = ActionView::Base.full_sanitizer.sanitize(decoded) if part.mime_type == 'text/html'

  puts "🧠 Decoded: #{decoded.truncate(200)}"
  decoded
rescue => e
  puts "⚠️ extract_body failed: #{e.message}"
  ""
end

# Recursively flatten all parts
def flatten_parts(part)
  return [part] unless part.parts&.any?
  part.parts.flat_map { |p| flatten_parts(p) }
end


end
