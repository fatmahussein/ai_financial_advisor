class ContactNote < ApplicationRecord
  belongs_to :contact
  belongs_to :user

  scope :similar_to, lambda { |vector, limit: 5|
    order(Arel.sql("embedding <-> '#{Pgvector::Vector.new(vector).to_sql}'")).limit(limit)
  }

  def self.embed_all_contact_notes(user)
    notes = where(user: user).where(embedding: nil).limit(100)
    batches = notes.in_groups_of(10, false)

    batches.each do |batch|
      texts = batch.map(&:body)
      embeddings = OllamaService.new(user).embed_batch(texts)

      batch.each_with_index do |note, idx|
        note.embedding = embeddings[idx]
        note.save!
      end
    end
  end
end
