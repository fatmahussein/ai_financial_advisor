class ChatsController < ApplicationController
  def index; end

  def new
    @chat = Chat.create!(title: 'New Chat')
    redirect_to chat_path(@chat)
  end

  def show
    @chat = Chat.find(params[:id])
  end

  def history
    @chats = Chat.order(created_at: :desc)
  end

  def create_message; end
end
