module Tools
  class GmailTool
    def initialize(user)
      @user = user
      @client = GmailClient.new(user) # wrapper for Gmail API
    end

    def send_email(to:, subject:, body:)
      @client.send_email(
        to: to,
        subject: subject,
        body: body
      )
    end
  end
end
