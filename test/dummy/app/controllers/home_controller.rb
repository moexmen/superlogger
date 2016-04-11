class HomeController < ApplicationController
  def index
    Something.where(paper: '123', stone: '456').first
  end
end
