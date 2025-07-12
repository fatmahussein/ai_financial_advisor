class BackfillContactNoteEmbeddingsWithOllama
  def self.call(model = 'nomic-embed-text')
    ContactNote.where(embedding: nil).where.not(body: [nil, '']).find_each(batch_size: 20) do |note|
      embedding = OllamaEmbeddingGenerator.new(note.body, model).call

      if valid_embedding?(embedding)
        note.update!(embedding: embedding)
        puts "✅ Embedded note ID #{note.id}"
      else
        puts "⚠️ Invalid embedding for note ID #{note.id} (got: #{embedding.class}, size: #{embedding&.size})"
      end
    rescue StandardError => e
      puts "❌ Failed to embed note #{note.id}: #{e.class} - #{e.message}"
    end
  end

  def self.valid_embedding?(embedding)
    embedding.is_a?(Array) && embedding.size == 768 && embedding.all? { |v| v.is_a?(Float) || v.is_a?(Numeric) }
  end
end
