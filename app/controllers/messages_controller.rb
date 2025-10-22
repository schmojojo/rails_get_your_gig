# Summary: Handles user-submitted messages, forwards user queries (with an events list and system prompt) to RubyLLM,
# saves the assistant's response as a Message, and exposes index/new actions for message viewing/creation.

# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  before_action :authenticate_user!

  SYSTEM_PROMPT = <<~PROMPT
    You are an AI assistant that helps users find events in our app.

    You know the events available (titles, categories, dates, locations) and only suggest events that match the user's query.

    Always answer in clear, concise sentences or bullet points.
    If no events match, politely say: "No matching events found."

    Do not suggest events that don't exist in the provided list.
    Use Markdown formatting if listing multiple events.
  PROMPT

  def create
    # Step 1: save user message
    @message = Message.new(
      role: "user",
      content: params[:message][:content],
      user: current_user # optional if your Message has user association
    )

    if @message.save
      ruby_llm_chat = RubyLLM.chat

      # Step 2: add context (all events)
      instructions = <<~PROMPT
        #{SYSTEM_PROMPT}

        Here are the events available:
        #{Event.all.order(date: :asc).map { |e| "- #{e.title} | #{e.category} | #{e.date}" }.join("\n")}

        Only return events that match the user's query below.
      PROMPT

      # Step 3: get AI response
      response = ruby_llm_chat.with_instructions(instructions).ask(@message.content)

      # Step 4: save assistant message
      Message.create(
        role: "assistant",
        content: response.content,
        user: current_user
      )

      redirect_to messages_path, notice: "AI response generated ✅"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @messages = Message.all.order(created_at: :asc)
  end

  def new
    @message = Message.new
  end
end
