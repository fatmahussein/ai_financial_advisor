class SimilaritySearchService
  def initialize(user, query)
    @user = user
    @query = query
  end

  def call
    embedding = EmbeddingGenerator.new(@query).call
    return [] unless embedding

    top_emails = Email.where(user: @user).where.not(embedding: nil).similar_to(embedding, limit: 5)
    top_notes  = Note.where(user: @user).where.not(embedding: nil).similar_to(embedding, limit: 5)

    (top_emails + top_notes).sort_by do |record|
      cosine_distance(embedding, record.embedding)
    end
  end

  private

  def cosine_distance(vec1, vec2)
    dot_product = vec1.zip(vec2).map { |a, b| a * b }.sum
    norm1 = Math.sqrt(vec1.map { |v| v**2 }.sum)
    norm2 = Math.sqrt(vec2.map { |v| v**2 }.sum)
    1 - dot_product / (norm1 * norm2)
  end
end
