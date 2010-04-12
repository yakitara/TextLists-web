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
      redirect_to list_path(@list)
    else
      render :show
    end
  end
  
  def destroy
    @list = List.find(params[:id])
    @list.destroy
    redirect_to root_path
  end
end
