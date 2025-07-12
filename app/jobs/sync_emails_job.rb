class SyncEmailsJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    GmailService.new(user).fetch_and_store_messages
  end
end
