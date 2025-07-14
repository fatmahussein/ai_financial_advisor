class ToolCallService
  def initialize(user)
    raise ArgumentError, "User is nil!" if user.nil?
    @user = user
  end

  def call_tool(tool_name, arguments)
    case tool_name
    when "send_email"
      # arguments[:subject] ||= "(No subject)"
      GmailClient.new(@user).send_email(**arguments.symbolize_keys)

   when "create_calendar_event"
  arguments[:title] 
  arguments[:start_time] ||= Time.now.utc.iso8601
  arguments[:end_time] ||= (Time.now.utc + 1.hour).iso8601

  result = Tools::CalendarTool.new(@user).create_event(**arguments.symbolize_keys)

  if result.is_a?(Google::Apis::CalendarV3::Event)
    start = result.start.date_time.in_time_zone("Africa/Nairobi")
    formatted_time = start.strftime("%-I:%M %p, %B %d")
    return "📅 Event created: #{result.summary} at #{formatted_time}"
  end

  result


    when "create_contact"
      Tools::HubspotTool.new(@user).create_contact(**arguments.symbolize_keys)

    when "add_note_to_contact"
      Tools::HubspotTool.new(@user).add_note(**arguments.symbolize_keys)

    else
      raise ArgumentError, "Unknown tool: #{tool_name}"
    end
  end
end
