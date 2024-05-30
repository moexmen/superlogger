class HomeController < ApplicationController
  def index
    Something.where(paper: '123', stone: '456').first
  end

  def index_with_session
    # Force load session by writing to it.
    session[:current_time] = Time.now
    redirect_to action: :index
  end
end
