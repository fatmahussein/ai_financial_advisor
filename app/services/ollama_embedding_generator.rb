require 'httparty'

class OllamaEmbeddingGenerator
  def initialize(text, model = "nomic-embed-text")
    @text = text
    @model = model
  end

  def call
    response = HTTParty.post("http://localhost:11434/api/embeddings",
      headers: { 'Content-Type' => 'application/json' },
      body: {
        model: @model,
        prompt: @text
      }.to_json
    )

    if response.code == 200
      response.parsed_response["embedding"]
    else
      Rails.logger.error("Ollama embedding error: #{response.body}")
      nil
    end
  end
end
