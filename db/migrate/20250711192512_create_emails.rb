class CreateEmails < ActiveRecord::Migration[8.0]
  def change
    create_table :emails do |t|
      t.references :user, null: false, foreign_key: true
      t.string :gmail_id
      t.string :subject
      t.string :sender
      t.text :snippet
      t.text :body
      t.datetime :received_at

      t.timestamps
    end
  end
end
