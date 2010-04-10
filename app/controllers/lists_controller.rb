class ListsController < ApplicationController
  def index
    # TODO: 
  end
  
  def new
    @list = List.new
    render :show
  end
  
  def create
    @list = List.new(params[:list])
    if @list.save
      redirect_to root_path
    else
      render :show
    end
  end
end
