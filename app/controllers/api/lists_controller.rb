class Api::ListsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :set_lists
  before_filter :api_key_required

  around_filter do |controller, action|
    List.with_user_scope(current_user) do
      action.call
    end
  end

  def create
    @list = List.new(params[:list])
    respond_to do |format|
      if @list.save
        format.json do
          render :json => {:id => @list.id}
        end
      else
        format.json do
          render :json => {:id => nil, :errors => @list.errors.full_messages}, :status => 400
        end
      end
    end
  end
end
