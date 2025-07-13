class RagService
  MAX_BODY_LENGTH = 1000
  GREETINGS = /\A(hi|hello|hey|howdy|good morning|good afternoon|good evening)\W*\z/i

  def initialize(user)
    @user = user
    @ollama = OllamaService.new(user)
  end

  def ask(query)
    return 'Hi, how may I assist you today?' if query.match?(GREETINGS)

    emails = retrieve_relevant(Email, query)
    notes = retrieve_relevant(ContactNote, query)

    return 'No relevant emails or notes found.' if emails.blank? && notes.blank?

    puts "🔍 Retrieved #{emails.size} emails and #{notes.size} contact notes"
    emails.each { |e| puts "  - Email ID: #{e.id}" }
    notes.each { |n| puts "  - Note ID: #{n.id}" }

    prompt = build_prompt(emails, notes, query)
    @ollama.answer(prompt, stream: true)
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
end
