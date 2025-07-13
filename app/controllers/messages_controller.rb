class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    message_text = params[:message]
    # Create user message
    @user_message = @chat.messages.create!(content: message_text, role: 'user')
    # Set title if chat doesn't have one yet
    if @chat.title.blank?
      short_title = message_text.truncate(50) # Limit to 50 characters
      @chat.update(title: short_title)
    end

    # Get AI response
    ai_response = RagService.new(current_user).ask(message_text)

    # Save AI response
    @ai_message = @chat.messages.create!(content: ai_response, role: 'ai')

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path }
    end
  end
end
