class EventsController < ApplicationController
  before_action :authenticate_user!, only: :new

  def index
    @events = Event.all.order(date: :asc)
    @event = Event.new if user_signed_in?
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.new(event_params)
    if @event.save
      redirect_to root_path, notice: "Event created ✅"
    else
      @events = Event.all
      render :index, status: :unprocessable_entity
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :contact, :date, :category, :location)
  end
end
