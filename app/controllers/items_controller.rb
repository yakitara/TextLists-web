class ItemsController < ApplicationController
  before_filter do
    @list = List.find_by_id(params[:list_id])
  end

  def index
    @items = Item
    if @list
      @items = @items.includes(:listings).where("listings.list_id" => @list)
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
end
