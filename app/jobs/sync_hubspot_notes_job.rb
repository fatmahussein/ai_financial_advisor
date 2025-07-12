class SyncHubspotNotesJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    Hubspot::Client.new(user).sync_notes!
  end
end
