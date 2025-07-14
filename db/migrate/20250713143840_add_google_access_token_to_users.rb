class AddGoogleAccessTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :google_access_token, :string
  end
end
