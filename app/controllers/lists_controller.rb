class ListsController < ApplicationController
  before_filter :login_required
  around_filter do |controller, action|
    List.with_user_scope(current_user) do
      action.call
    end
  end
  
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
    @list.done!
    redirect_to root_path
  end
  
  def sort
    params[:list].each.with_index do |id, pos|
      List.update_all({:position => pos}, {:id => id})
    end
  end
end
