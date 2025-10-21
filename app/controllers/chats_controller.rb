class ChatsController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat = Chat.new
    @chat.user = current_user
    @chat.save
    redirect_to chat_path(@chat)
  end

  def show
    @chat = Chat.find(params[:id])
  end
end
