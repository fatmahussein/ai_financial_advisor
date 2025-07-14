class RagService
  MAX_BODY_LENGTH = 1000
  GREETINGS = /\A(hi|hello|hey|howdy|good morning|good afternoon|good evening)\W*\z/i

  def initialize(user)
    @user = user
    @ollama = OllamaService.new(user)
  end

  def ask(query)
    return ['Hi, how may I assist you today?', nil] if query.match?(GREETINGS)

    emails = retrieve_relevant(Email, query)
    notes = retrieve_relevant(ContactNote, query)

    prompt = build_prompt(emails, notes, query)
    ai_response = @ollama.answer(prompt)

    tool_call = extract_tool_call(ai_response)
    display_text = if tool_call
                     "✉️ Sending an email to #{tool_call.dig(:arguments, :to)}..."
                   else
                     ai_response
                   end

    [display_text, tool_call]
  end

  private

  def retrieve_relevant(model, query, limit: 5)
    query_embedding = @ollama.embed(query)
    return [] if query_embedding.blank?

    model.where(user: @user)
      .order(Arel.sql("embedding <#> '[#{query_embedding.join(',')}]'"))
      .limit(limit)
  end

  def build_prompt(emails, notes, query)
    summarizer = SummarizationService.new(@user)

    email_summaries = emails.map.with_index do |email, i|
      summary = summarizer.summarize(email.body.to_s[0...MAX_BODY_LENGTH])
      "--- Email Summary #{i + 1}:\n#{summary.strip}"
    end

    note_summaries = notes.map.with_index do |note, i|
      summary = summarizer.summarize(note.body.to_s[0...MAX_BODY_LENGTH])
      "--- Note Summary #{i + 1}:\n#{summary.strip}"
    end

    all_summaries = (email_summaries + note_summaries).join("\n\n")

    prompt = <<~PROMPT
      Based on the following summaries of client emails and contact notes, #{query}:

      #{all_summaries}
    PROMPT

    puts "📝 Prompt length: #{prompt.length} characters"
    prompt[0...OllamaService::MAX_PROMPT_LENGTH]
  end

  def extract_tool_call(response)
    json = begin
      JSON.parse(response)
    rescue StandardError
      nil
    end
    return nil unless json.is_a?(Hash) && json['tool_call']

    {
      tool_name: json['tool_call']['name'],
      arguments: json['tool_call']['args']
    }
  rescue StandardError => e
    puts "⚠️ Tool call extraction error: #{e.message}"
    nil
  end
end
