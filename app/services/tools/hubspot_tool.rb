module Tools
  class HubspotTool
    def initialize(user)
      @user = user
      @client = HubspotClient.new(user) # wrapper for HubSpot API
    end

    def create_contact(name:, email:)
      @client.create_contact(name: name, email: email)
    end

    def add_note(contact_id:, content:)
      @client.create_note_for_contact(contact_id: contact_id, content: content)
    end
  end
end
