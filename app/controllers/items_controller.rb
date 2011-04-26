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
      @items = @list.items.select("items.*, listings.id AS listed_listing_id")
    else
      @items = Item
    end
    @items = @items.all
  end
  
  # index of done items
  def done
    @items = Item.includes(:listings => :list).where("listings.deleted_at IS NOT NULL").order('listings.deleted_at DESC').paginate(:page => params[:page])
  end
  
#   def show
#     @item = Item.find(params[:id])
# #    content_for :title, "#{@item.} - #{Rails.application.config.app_name}"
#   end
  
  # def new
  #   @item = Item.new
  #   @item.listings.build(:list => @list)
  #   render :show
  # end
  
  def create
    # @item = Item.new(params[:item])
    if @list
      @item = @list.items.build(params[:item])
    else
      @item = Item.new(params[:item])
    end
    
    if @item.save
      render :partial => @item, :locals => {:list => @list, :selectable_lists => @lists}
    #   redirect_to(@list ? [@list, :items] : root_path)
    # else
    #   render :show
    end
  end
  
  def update
    @item = Item.find(params[:id])
    if @item.update_attributes(params[:item])
      title_html = render_to_string(:partial => "title.html", :locals => {:item => @item})
      render :json => {:title => title_html}
    end
  end
  
  def sort
    params[:item].each.with_index do |item_id, pos|
      Listing.where(:list_id => @list, :item_id => item_id).first.update_attributes!(:position => pos)
    end
    render :nothing => true
  end
end
