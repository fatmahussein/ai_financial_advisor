require 'google/apis/calendar_v3'

module Tools
  class CalendarTool
    def initialize(user)
      @user = user
      @service = Google::Apis::CalendarV3::CalendarService.new
      @service.authorization = Signet::OAuth2::Client.new(
        access_token: user.google_access_token
      )
    end

    def create_event(summary:, start_time:, end_time:, attendees: [], description: nil)
      event = Google::Apis::CalendarV3::Event.new(
        summary: summary,
        description: description,
        start: Google::Apis::CalendarV3::EventDateTime.new(date_time: start_time),
        end:   Google::Apis::CalendarV3::EventDateTime.new(date_time: end_time),
        attendees: attendees.map { |email| { email: email } }
      )

      result = @service.insert_event('primary', event)
      return result

      
    rescue => e
      puts "❌ Calendar event error: #{e.message}"
      "Something went wrong creating the calendar event."
    end
  end
end
