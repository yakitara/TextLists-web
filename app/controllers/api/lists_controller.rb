class Api::ListsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :set_lists
  before_filter :api_key_required

  around_filter do |controller, action|
    List.with_user_scope(current_user) do
      action.call
    end
  end
  
  def show
    @list = List.find(params[:id])
    render :json => @list
  end
  
  def show
    @list = List.find(params[:id])
    render :json => @list
  end
  
  def create
    @list = List.new(params[:list])
    if @list.save
      render :json => {:id => @list.id}
    else
      render :json => {:id => nil, :errors => @list.errors.full_messages}, :status => 400
    end
  end
  
  def update
    @list = List.find(params[:id])
    if @list.update_attributes(params[:list])
      render :json => {:id => @list.id}
    else
      render :json => {:id => nil, :errors => @list.errors.full_messages}, :status => 400
    end
  end
end
