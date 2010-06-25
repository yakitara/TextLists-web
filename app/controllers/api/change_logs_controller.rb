class Api::ChangeLogsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :set_lists
  before_filter :api_key_required
  
  respond_to :json
  
  def create
    klass = params[:type].camelcase.constantize
    @record = params[:id] ? klass.find(params[:id]) : klass.new(:user => current_user)
    if @record.update_attributes(params[:change])
      render :json => {:id => @record.id}
    else
      render :json => {:errors => @record.errors.full_messages}, :status => :unprocessable_entity
    end
  end
end
