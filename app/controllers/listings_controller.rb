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
    @item = current_user.items.find(params[:item_id])
    @item.move!(current_user.lists.find(params[:list_id]), List.find(params[:listing][:list_id]))
    if request.xhr?
      render :json => {:list_id => params[:listing][:list_id], :item_id => @item.id}
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

  def undone
    conds = params.slice(:item_id, :id)
    @listing = Listing.unscoped.where(:user_id => current_user).where(conds).first
    @listing.update_attributes!(:deleted_at => nil)
    if request.xhr?
      render :json => conds
    else
      redirect_to done_items_path
    end
  end
end
