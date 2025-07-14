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
    tools = <<~TOOLS
        Available tools:

          1. create_calendar_event
        - Use this tool to add events to the user's Google Calendar.
        - Required arguments:
        - summary: Title of the event
        - start_time: Start time (ISO 8601 format)
        - end_time: End time (ISO 8601 format)
        - attendees (optional): Array of email addresses
        - description (optional): Extra info

        If the prompt is a request to schedule something, respond like:

      {
        "tool_call": {
          "name": "create_calendar_event",
          "args": {
            "summary": "Investment Review with Sara",
            "start_time": "2025-07-14T15:00:00+03:00",
            "end_time": "2025-07-14T16:00:00+03:00",
            "attendees": ["sara@example.com"],
            "description": "Discuss investment updates."
          }
        }
      }

        Only output a JSON object with the tool call. Do not explain or add any other text unless no tool is needed.
    TOOLS

    full_prompt = "#{tools.strip}\n\n#{prompt.strip}"
    puts "🚀 Sending prompt (#{full_prompt.length} chars) to Ollama (chat endpoint)..."

    messages = [{ role: 'system', content: tools.strip }, { role: 'user', content: prompt.strip }]

    response = Faraday.post("#{BASE_URL}/api/chat") do |req|
      req.options.timeout = 120
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        model: model,
        messages: messages,
        stream: stream
      }.to_json
    end

    if stream
      stream_text = ''
      response.body.each_line do |line|
        json = JSON.parse(line)
        stream_text << json['message']['content'].to_s
        print json['message']['content']
      end
      stream_text
    else
      json = JSON.parse(response.body)
      json.dig('message', 'content')
    end
  rescue Faraday::TimeoutError
    'The response timed out. Please try again.'
  rescue StandardError => e
    puts "❌ Error: #{e.message}"
    'Something went wrong.'
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
