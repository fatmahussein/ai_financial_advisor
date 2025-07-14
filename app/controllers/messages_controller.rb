class MessagesController < ApplicationController
  before_action :authenticate_user!
  def create
    @chat = Chat.find(params[:chat_id])
    message_text = params[:message]

    @user_message = @chat.messages.create!(content: message_text, role: 'user')
    @chat.update(title: message_text.truncate(50)) if @chat.title.blank?

    rag_service = RagService.new(current_user)
    display_text, tool_call = rag_service.ask(message_text)
    puts "👤 Current user: #{current_user.inspect}"

    # Run tool if any
    tool_output = nil
    if tool_call
      tool_output = ToolCallService.new(current_user).call_tool(
        tool_call[:tool_name],
        tool_call[:arguments]
      )
    end

    final_response = tool_output || display_text
    @ai_message = @chat.messages.create!(content: final_response, role: 'ai')

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path }
    end
  end
end
