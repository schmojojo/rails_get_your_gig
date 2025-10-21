class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :events

  def events
  end

  def home
  end
end
