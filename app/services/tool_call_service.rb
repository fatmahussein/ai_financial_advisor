class ToolCallService
  def initialize(user)
    raise ArgumentError, 'User is nil!' if user.nil?

    @user = user
  end

  def call_tool(tool_name, arguments)
    case tool_name
    when 'send_email' then handle_send_email(arguments)
    when 'create_calendar_event' then handle_create_calendar_event(arguments)
    when 'create_contact' then handle_create_contact(arguments)
    when 'add_note_to_contact' then handle_add_note_to_contact(arguments)
    else raise ArgumentError, "Unknown tool: #{tool_name}"
    end
  end

  private

  def handle_send_email(arguments)
    GmailClient.new(@user).send_email(**arguments.symbolize_keys)
    "📧 Email sent to #{arguments[:to]} with subject: '#{arguments[:subject]}'"
  end

  def handle_create_calendar_event(arguments)
    arguments[:start_time] ||= Time.now.utc.iso8601
    arguments[:end_time] ||= (Time.now.utc + 1.hour).iso8601

    result = Tools::CalendarTool.new(@user).create_event(**arguments.symbolize_keys)

    if result.is_a?(Google::Apis::CalendarV3::Event)
      start = result.start.date_time.in_time_zone('Africa/Nairobi')
      formatted_time = start.strftime('%-I:%M %p, %B %d')
      return "📅 Event created: #{result.summary} at #{formatted_time}"
    end

    result
  end

  def handle_create_contact(arguments)
    Tools::HubspotTool.new(@user).create_contact(**arguments.symbolize_keys)
    "✅ Contact created: #{arguments[:name]}"
  end

  def handle_add_note_to_contact(arguments)
    Tools::HubspotTool.new(@user).add_note(**arguments.symbolize_keys)
    "🗒️ Note added to contact ID #{arguments[:contact_id]}"
  end
end
