class Email < ApplicationRecord
  belongs_to :user
  after_create_commit :generate_embedding

  scope :similar_to, ->(vector, limit: 5) {
    order(Arel.sql("embedding <-> '#{Pgvector::Vector.new(vector).to_sql}'")).limit(limit)
  }

  def self.search_by_embedding(query, user, limit: 5)
    query_embedding = OllamaService.new(user).embed(query)
    where(user: user)
      .order(Arel.sql("embedding <#> '#{Pgvector::Vector.new(query_embedding)}'"))
      .limit(limit)
  end

  def self.embed_all_emails(user)
    emails = where(user: user).where(embedding: nil).limit(100)
    batches = emails.in_groups_of(10, false)

    batches.each do |batch|
      texts = batch.map(&:body)
      embeddings = OllamaService.new(user).embed_batch(texts)

      batch.each_with_index do |email, idx|
        email.embedding = embeddings[idx]
        email.save!
      end
    end
  end

  private

  def generate_embedding
    return if body.blank? || embedding.present?
    update(embedding: OllamaEmbeddingGenerator.new(body).call)
  end
end
