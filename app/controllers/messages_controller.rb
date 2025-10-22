class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are an expert file clerk.\n\nI am a disorganized person, looking at an event calendar.\n\nCategorize the event list according to the keywords i give you.\n\nAnswer consicely in Markdown."

  def new
    @events = Event.all
    @message = Message.new
    @messages = Message.all
  end

  def create
    @events = Event.all
    @messages = Message.all
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

  def events_list
    text = "here's the info about the events in the db:"
    @events.each do |event|
      text += " event title: #{event.title}, location: #{event.location}, event date: #{event.date}, event category: #{event.category}, event description: #{event.description}, event contact: #{event.contact}"
    end
  end

  def instructions
    [SYSTEM_PROMPT, events_list].compact.join("\n\n")
  end

end
