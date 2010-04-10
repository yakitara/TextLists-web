class ListsController < ApplicationController
  def index
    # TODO: 
  end
  
  def new
    @list = List.new
    render :show
  end
  
  def create
    if @list = List.create(params[:list])
      redirect_to root_path
    else
      render :show
    end
  end
end
