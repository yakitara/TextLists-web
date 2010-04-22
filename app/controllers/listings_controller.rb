class ListingsController < ApplicationController
  before_filter :login_required
  
  def move
    # delete old listing
    old = Listing.first(:conditions => params.slice(:item_id, :list_id))
    old.destroy
    # insert new listing
    list = List.find(params[:listing][:list_id])
    list.listings.create!(params.slice(:item_id))
    redirect_to list_items_path(params[:list_id])
  end

  def destroy
    @item = Listing.first(:conditions => params.slice(:item_id, :list_id, :id))
    @item.destroy
    redirect_to list_items_path(params[:list_id])
  end
end
