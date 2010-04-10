class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter do
    @lists = List.all
  end
  
  def index
  end
end
