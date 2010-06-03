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
      # delete old listing
      old = Listing.first(:conditions => params.slice(:item_id, :list_id))
      old.destroy
      # insert new listing
      list = List.find(params[:listing][:list_id])
      list.listings.create!(params.slice(:item_id))
    end
    redirect_to list_items_path(params[:list_id])
  end

  def destroy
    @listing = Listing.first(:conditions => params.slice(:item_id, :list_id, :id))
    # @listing.destroy
    @listing.done!
    redirect_to list_items_path(params[:list_id])
  end
end
