class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.string :hubspot_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.datetime :created_at_hubspot
      t.datetime :updated_at_hubspot
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
