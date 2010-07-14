class Api::ItemsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :set_lists
  before_filter :api_key_required
#   before_filter do
#     user = User.find(params[:user_id])
#     if params[:key] == calculate_api_key(user.salt)
#       @current_user = user
#     else
#       render :nothing => true, :status => 403
#       false
#     end
#   end
  
  around_filter do |controller, action|
    Item.with_user_scope(current_user) do
      List.with_user_scope(current_user) do
        Listing.with_user_scope(current_user) do
          action.call
        end
      end
    end
  end
  
  def show
    @item = Item.find(params[:id])
    render :json => @item
  end
  
  def create
    @item = Item.new(params[:item])
    if list_name = params[:list]
      # @item.listings.build(:list => List.find_by_name(list_name))
      @item.listings.build(:list => current_user.inbox!)
    end
    
    respond_to do |format|
      if @item.save
        format.json do
          render :json => {:id => @item.id}
        end
        format.html do
          render :inline => <<-HTML
            <!DOCTYPE html>
            <html><body><script>window.close();</script></body></html>
          HTML
        end
      else
        format.json do
          render :json => {:id => nil, :errors => @item.errors.full_messages}, :status => 400
        end
        format.html do
          render :inline => <<-HTML
            <!DOCTYPE html>
            <html><body><%= error_messages_for @item %></body></html>
          HTML
        end
      end
    end
  end
  
  def update
    @item = Item.find(params[:id])
    if @item.update_attributes(params[:item])
      render :json => {:id => @item.id}
    else
      render :json => {:id => nil, :errors => @item.errors.full_messages}, :status => 400
    end
  end
end
