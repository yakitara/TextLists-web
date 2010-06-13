class Api::ListingsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :set_lists
  before_filter :api_key_required

  around_filter do |controller, action|
    Listing.with_user_scope(current_user) do
      action.call
    end
  end
  
  def show
    @listing = Listing.find(params[:id])
    render :json => @listing
  end
  
  def create
    @listing = Listing.new(params[:listing])
    if @listing.save
      render :json => {:id => @listing.id}
    else
      render :json => {:id => nil, :errors => @listing.errors.full_messages}, :status => 400
    end
  end

  def update
    @listing = Listing.find(params[:id])
    if @listing.update_attributes(params[:listing])
      render :json => {:id => @listing.id}
    else
      render :json => {:id => nil, :errors => @listing.errors.full_messages}, :status => 400
    end
  end
end
