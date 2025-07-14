require "google/apis/gmail_v1"
require "signet/oauth_2/client"
require "base64"
require "mail"

class GmailClient
 def initialize(user)
  raise ArgumentError, "User must be provided" if user.nil?
  @user = user
  @client = Google::Apis::GmailV1::GmailService.new
  @client.authorization = Signet::OAuth2::Client.new(
    access_token: @user.google_access_token
  )
end

  def send_email(to:, subject:, body:)
    sender_email = @user.email

    raw_message = build_raw_message(to: to, subject: subject, body: body)

    message_object = Google::Apis::GmailV1::Message.new(raw: raw_message)

    @client.send_user_message('me', message_object)
  rescue Google::Apis::ClientError => e
    puts "❌ Gmail API ClientError: #{e.message}"
    raise
  rescue => e
    puts "❌ Unexpected error: #{e.message}"
    raise
  end

  private

  def build_raw_message(to:, subject:, body:)
    mail = Mail.new do
      from    @user.email
      to      to
      subject subject
      body    body
    end

    mail.content_type = 'text/plain; charset=UTF-8'

    puts "📧 RAW MIME:\n#{mail.encoded}"

    Base64.urlsafe_encode64(mail.encoded)
  end
end
