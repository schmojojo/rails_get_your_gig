class MessagesController < ApplicationController
  before_action :authenticate_user!
  SYSTEM_PROMPT = "You are an expert file clerk helping a disorganized person categorize events from a calendar. Use the user's keywords to create categories and list the relevant events under each. Answer concisely in Markdown."

  def index
    @messages = current_user.messages.order(created_at: :asc)
    @message = Message.new
  end

  def create
    user_message = current_user.messages.create(message_params.merge(role: "user"))
    ai_client = RubyLLM.chat
    response = ai_client.with_instructions(instructions).ask(user_message.content)
    current_user.messages.create(role: "assistant", content: response.content)
    redirect_to messages_path
  end

  # def new
  #   @events = Event.all
  #   @message = Message.new
  #   @messages = Message.all
  # end

  # def create
  #   @events = Event.all
  #   @messages = Message.all
  #   @message = Message.new(role: "User", content: params[:message][:content])
  #   if @message.save
  #     @ruby_llm_chat = RubyLLM.chat
  #     response = @ruby_llm_chat.with_instructions(instructions).ask(@message.content)
  #     Message.create(role: "Assistant", content: response.content)
  #     redirect_to new_message_path
  #   else
  #     render :new, status: :unprocessable_entity
  #   end

  private

 def message_params
    params.require(:message).permit(:content)
  end

  def event_context
    events = Event.all.order(date: :asc)

    event_details = events.map do |event|
      "- Title: #{event.title}, Date: #{event.date}, Location: #{event.location}, Category: #{event.category}"
    end

    "Here is the current list of available events:\n#{event_details.join("\n")}"
  end

  def instructions
    [SYSTEM_PROMPT, event_context].join("\n\n")
  end

end
