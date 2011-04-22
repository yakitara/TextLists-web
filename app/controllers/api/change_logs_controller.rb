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
    changes = params[:changes] || [params.slice(:json, :user_id, :record_type, :record_id)]
    
    results = changes.map do |change|
      log = ChangeLog.recognize(change)
      if log.accept
        {:id => log.record_id }
      else
        {:errors => log.errors.full_messages}
      end
    end
    
    if results.size > 1
      logger.info "  API Response: #{results.to_json}"
      render :json => results
    else
      result = results.first
      logger.info "  API Response: #{result.to_json}"
      unless result.has_key?(:errors)
        render :json => result
      else
        render :json => result, :status => :unprocessable_entity
      end
    end    
  end
  
  def next
    # if limit > 1, responses array of logs
    limit = [params[:limit].to_i, 1].max
    logs = ChangeLog.where("id > ?", params[:id].to_i).limit(limit).all
    if logs.present?
      value = limit > 1 ? logs : logs.first
      logger.info "  API Response: #{value.to_json}"
      render :json => value
    else # logs no more
      render :nothing => true, :status => :no_content
    end
  end
end
