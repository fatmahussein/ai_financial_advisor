class CreateRules < ActiveRecord::Migration[8.0]
  def change
    create_table :rules do |t|
      t.references :user, null: false, foreign_key: true
      t.string :condition
      t.string :action

      t.timestamps
    end
  end
end
