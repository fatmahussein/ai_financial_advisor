class AddEmbeddingToEmails < ActiveRecord::Migration[8.0]
  def change
     add_column :emails, :embedding, :vector, limit: 1536
  end
end
