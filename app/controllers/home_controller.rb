class HomeController < ApplicationController
  before_action :authenticate_user!

  def index; end

  def sync_emails
    GmailService.new(current_user).fetch_and_store_messages
    redirect_to home_index_path, notice: 'Emails synced!'
  end
end
