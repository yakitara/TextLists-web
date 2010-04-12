class ListsController < ApplicationController
  def show
    redirect_to list_items_path(params[:id])
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
  
  def update
    @list = List.find(params[:id])
    if @list.update_attributes(params[:list])
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
