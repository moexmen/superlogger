class HomeController < ApplicationController
  def index
    Something.where(paper: '123', stone: '456').first
  end

  def index_with_session
    session[:force_load_session] = 'By writing to it'
    redirect_to action: :index
  end
end
