class Api::ListingsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :set_lists
  before_filter :api_key_required

  around_filter do |controller, action|
    Listing.with_user_scope(current_user) do
      action.call
    end
  end

  def create
    @listing = Listing.new(params[:listing])
    respond_to do |format|
      if @listing.save
        format.json do
          render :json => {:id => @listing.id}
        end
      else
        format.json do
          render :json => {:id => nil}, :status => 401
        end
      end
    end
  end
end
