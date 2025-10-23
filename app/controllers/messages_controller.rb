class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are an expert file clerk.\n\nI am a beginner file clerck, looking at an event calendar.\n\nHelp me display the #{@events} that match my keywords and show title, description, date, location, contact and category.\n\nAnswer consicely in Markdown."

  def new
    @events = Event.all
    @message = Message.new
    @messages = Message.all
  end

  def create
    @events = Event.all
    @messages = Message.all
    @messages.destroy_all
    @message = Message.new(role: "User", content: params[:message][:content])
    if @message.save
      @ruby_llm_chat = RubyLLM.chat
      response = @ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      Message.create(role: "Assistant", content: response.content)
      redirect_to new_message_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

 def message_params
    params.require(:message).permit(:content)
  end

  def event_context
    text = "here's the info about the events in the db:"
    @events.each do |event|
      text += " Title: #{event.title}, Description: #{event.description} Date: #{event.date}, Location: #{event.location}, Category: #{event.category}, contact: #{event.contact}"
    end
    text
  end

  def instructions
    [SYSTEM_PROMPT, event_context].join("\n\n")
  end
end
