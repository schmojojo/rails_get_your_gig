class EventsController < ApplicationController
  before_action :authenticate_user!, only: [:create]
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @events = Event.all.order(date: :asc)
    # @events = Event.order(date: :asc).limit(params[:limit] || 6)
    # @total_count = Event.count
    @event = Event.new if user_signed_in?
  end

  # optional: endpoint for loading more
  # def load_more
  #   offset = params[:offset].to_i
  #   limit = 6
  #   @events = Event.order(date: :asc).offset(offset).limit(limit)
  #   render partial: "events/event_cards", locals: { events: @events }
  # end


  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.new(event_params)
    if @event.save
      redirect_to events_path, notice: "Event created ✅"
    else
      @events = Event.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @event.update(event_params)
    redirect_to event_path(@event)
  end

  def destroy
    @event.destroy
    redirect_to events_path, status: :see_other
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :contact, :date, :category, :location, :photo)
  end
end
