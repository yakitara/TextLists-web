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
      # @items = @items.includes(:listings).where("listings.list_id" => @list).order("listings.position ASC")
      @items = @list.items.select("items.*, listings.id AS listed_listing_id")
    else
      @items = Item
    end
    @items = @items.all
  end
  
  def show
    @item = Item.find(params[:id])
  end
  
  def new
    @item = Item.new
    @item.listings.build(:list => @list)
    render :show
  end
  
  def create
    @item = Item.new(params[:item])
    if @item.save
      redirect_to(@list ? [@list, :items] : root_path)
    else
      render :show
    end
  end
  
  def update
    @item = Item.find(params[:id])
    if @item.update_attributes(params[:item])
      redirect_to(@list ? [@list, :items] : root_path)
    else
      render :show
    end
  end
  
  def sort
    params[:item].each.with_index do |item_id, pos|
      Listing.where(:list_id => @list, :item_id => item_id).first.update_attributes!(:position => pos)
    end
    render :nothing => true
  end
end
