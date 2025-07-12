class AddHubspotFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :hubspot_access_token, :string
    add_column :users, :hubspot_refresh_token, :string
    add_column :users, :hubspot_token_expires_at, :datetime
  end
end
