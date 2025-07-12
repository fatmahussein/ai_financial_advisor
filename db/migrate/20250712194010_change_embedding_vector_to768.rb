class ChangeEmbeddingVectorTo768 < ActiveRecord::Migration[8.0]
  def change
    change_column :emails, :embedding, :vector, limit: 768
  end
end
