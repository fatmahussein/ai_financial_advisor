class Email < ApplicationRecord
  belongs_to :user
  after_create_commit :generate_embedding

  private

  def generate_embedding
    return if body.blank? || embedding.present?

    update(embedding: OllamaEmbeddingGenerator.new(body).call)
  end
end
