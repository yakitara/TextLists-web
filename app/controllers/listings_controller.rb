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
      @listing.position = 0
      @listing.save!
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
