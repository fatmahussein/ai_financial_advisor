class BackfillEmailEmbeddingsWithOllama
  def self.call(model = 'nomic-embed-text')
    Email.where(embedding: nil).where.not(body: [nil, '']).find_each(batch_size: 20) do |email|
      embedding = OllamaEmbeddingGenerator.new(email.body, model).call

      if valid_embedding?(embedding)
        email.update!(embedding: embedding)
        puts "✅ Embedded email ID #{email.id}"
      else
        puts "⚠️ Invalid embedding for email ID #{email.id} (got: #{embedding.class}, size: #{embedding&.size})"
      end
    rescue StandardError => e
      puts "❌ Failed to embed email #{email.id}: #{e.class} - #{e.message}"
    end
  end

  def self.valid_embedding?(embedding)
    embedding.is_a?(Array) && embedding.size == 768 && embedding.all? { |v| v.is_a?(Float) || v.is_a?(Numeric) }
  end
end
