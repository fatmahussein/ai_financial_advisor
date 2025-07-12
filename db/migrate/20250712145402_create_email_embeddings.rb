class CreateEmailEmbeddings < ActiveRecord::Migration[8.0]
  def change
   create_table :email_embeddings do |t|
      t.references :email, null: false, foreign_key: true, index: { unique: true }
      t.vector :embedding, limit: 1536, null: false

      t.timestamps
    end
  end
end
