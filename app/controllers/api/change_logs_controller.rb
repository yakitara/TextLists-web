class Api::ChangeLogsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :set_lists
  before_filter :api_key_required
  
  around_filter do |controller, action|
    ChangeLog.with_user_scope(current_user) do
      action.call
    end
  end
  
  respond_to :json
  
  def create
    @log = ChangeLog.recognize(params.slice(:json, :user_id, :record_type, :record_id))
    if @log.accept
      render :json => {:id => @log.record.id}
    else
      render :json => {:errors => @log.errors.full_messages}, :status => :unprocessable_entity
    end
#     klass = params[:record_type].camelcase.constantize
#     @record = params[:record_id] ? klass.find(params[:record_id]) : klass.new(:user => current_user)
#     if @record.merge(params[:change])
#       render :json => {:id => @record.id}
#     else
#       render :json => {:errors => @record.errors.full_messages}, :status => :unprocessable_entity
#     end
  end
  
  def next
    # TODO: refactoring. move the logic into the model. and consider how to be DRY those codes...
    if next_log = ChangeLog.where("id > ?", params[:id].to_i).first
      @logs = ChangeLog.where("record_type = ? AND record_id = ? AND changed_at >= ? AND id != ?", next_log.record_type, next_log.record_id, next_log.changed_at, next_log.id).order("changed_at ASC").all
      change = ActiveSupport::JSON.decode(next_log.json)
      @logs.each do |log|
        change.update(ActiveSupport::JSON.decode(log.json))
      end
      next_log.json = change.merge(change){|k, v| v.as_json }.to_json
      render :json => next_log
    else # logs no more
      render :nothing => true, :status => :no_content
    end
  end
end
