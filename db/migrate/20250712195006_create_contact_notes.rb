class CreateContactNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_notes do |t|
      t.references :contact, null: false, foreign_key: true
      t.string :hubspot_id
      t.text :body
      t.vector :embedding, limit: 768

      t.timestamps
    end
  end
end
