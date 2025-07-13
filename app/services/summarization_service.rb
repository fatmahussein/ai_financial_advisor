class SummarizationService
  def initialize(user)
    @ollama = OllamaService.new(user)
  end

  def summarize(text)
    prompt = <<~PROMPT
      Summarize the following client communication in one sentence:

      #{text}
    PROMPT

    @ollama.answer(prompt)
  end
end
