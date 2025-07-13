require 'faraday'
require 'json'

class OllamaService
  BASE_URL = 'http://localhost:11434'.freeze
  MAX_PROMPT_LENGTH = 5000
  HEADERS = { 'Content-Type' => 'application/json' }.freeze

  def initialize(user)
    @user = user
  end

  def answer(prompt, model = 'llama3', stream: false)
    prompt = prompt[0...MAX_PROMPT_LENGTH] if prompt.length > MAX_PROMPT_LENGTH
    puts "🚀 Sending prompt (#{prompt.length} chars) to Ollama..."

    begin
      response = Faraday.post("#{BASE_URL}/api/generate") do |req|
        req.options.timeout = 60
        req.headers['Content-Type'] = 'application/json'
        req.body = { model: model, prompt: prompt, stream: stream }.to_json
      end

      if stream
        stream_text = ''
        response.body.each_line do |line|
          json = JSON.parse(line)
          stream_text << json['response'].to_s
          print json['response']
        end
        stream_text
      else
        JSON.parse(response.body)['response']
      end
    rescue Faraday::TimeoutError
      'The response timed out. Please try again.'
    rescue StandardError => e
      puts "❌ Error: #{e.message}"
      'Something went wrong.'
    end
  end

  def embed(text)
    puts "📨 Embedding single text: #{text.inspect}"

    response = Faraday.post("#{BASE_URL}/api/embeddings") do |req|
      req.options.timeout = 30
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        model: 'nomic-embed-text:latest',
        prompt: text # ✅ single string
      }.to_json
    end

    puts "📦 Raw embedding response: #{response.body}"
    json = JSON.parse(response.body)

    embedding = json['embedding']
    puts "🔧 Got embedding: #{embedding.inspect}"
    embedding.presence
  rescue StandardError => e
    puts "❌ Embedding error: #{e.message}"
    nil
  end

  def embed_batch(texts)
    texts.map do |text|
      embed(text) # individually
    end
  end
end
