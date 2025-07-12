class AddEmbeddingToEmails < ActiveRecord::Migration[8.0]
  def change
    execute "CREATE INDEX index_emails_on_embedding ON emails USING ivfflat (embedding vector_cosine_ops)"
  end
end
