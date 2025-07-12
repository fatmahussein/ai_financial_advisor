class AddHubspotTimestampsToContactNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :contact_notes, :created_at_hubspot, :datetime
    add_column :contact_notes, :updated_at_hubspot, :datetime
  end
end
