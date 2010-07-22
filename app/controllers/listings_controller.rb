class ListingsController < ApplicationController
  before_filter :login_required
  
  around_filter do |controller, action|
    List.with_user_scope(current_user) do
      Item.with_user_scope(current_user) do
        Listing.with_user_scope(current_user) do
          action.call
        end
      end
    end
  end
  
  def move
    Listing.transaction do
      @listing = Listing.first(:conditions => params.slice(:item_id, :list_id))
      @listing.list = List.find(params[:listing][:list_id])
      @listing.save!
#       # delete old listing
#       old = Listing.first(:conditions => params.slice(:item_id, :list_id))
#       old.destroy
#       # insert new listing
#       list = List.find(params[:listing][:list_id])
#       list.listings.create!(params.slice(:item_id))
    end
    if request.xhr?
      render :json => {:item_id => @listing.item_id}
    else
      redirect_to list_items_path(params[:list_id])
    end
  end

  def destroy
    conds =  params.slice(:item_id, :list_id, :id)
    @listing = Listing.first(:conditions => conds)
    @listing.done!
    if request.xhr?
      render :json => conds
    else
      redirect_to list_items_path(params[:list_id])
    end
  end
end
