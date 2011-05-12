class ItemsController < ApplicationController
  before_filter :login_required
  
  before_filter do
    @list = List.find_by_id(params[:list_id])
  end
  
  around_filter do |controller, action|
    Item.with_user_scope(current_user) do
      Listing.with_user_scope(current_user) do
        action.call
      end
    end
  end
  
  def index
    if @list
      @items = @list.items.select("items.*, listings.id AS listed_listing_id").includes(:listings, :labels)
    else
      @items = Item
    end
    @items = @items.all
  end
  
  # index of done items
  def done
    @items = Item.includes(:listings => :list).where("listings.deleted_at IS NOT NULL").order('listings.deleted_at DESC').paginate(:page => params[:page])
  end
  
  def create
    if @list
      @item = @list.items.build(params[:item])
    else
      @item = Item.new(params[:item])
    end
    
    if @item.save
      respond_to do |format|
        format.html { render :partial => @item, :locals => {:list => @list, :selectable_lists => @lists} }
        format.json { render :json => {:id => @item.id} }
      end
    end
  end
  
  def update
    @item = Item.find(params[:id])
    if @item.update_attributes(params[:item])
      title_html = render_to_string(:partial => "title.html", :locals => {:item => @item})
      attributes_html = render_to_string(:partial => "attributes.html", :locals => {:item => @item})
      render :json => {:title => title_html, :attributes => attributes_html}
    end
  end
  
  def sort
    params[:item].each.with_index do |item_id, pos|
      Listing.where(:list_id => @list, :item_id => item_id).first.update_attributes!(:position => pos)
    end
    render :nothing => true
  end
end
