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
    case params[:version]
    when "0.3"
      # responses array of logs (<= :limit)
      logs = ChangeLog.where("id > ?", params[:change_id]).limit(params[:limit]).all
      if logs.empty?
        logs = ChangeLog.where(:id => params[:change_id]).where("changed_at > created_at").all
      end

      if logs.present?
        logger.info "  API Response: #{logs.to_json}"
        render :json => logs
      else # logs no more
        render :nothing => true, :status => :no_content
      end
    else # old version
      log = ChangeLog.where("id > ?", params[:id]).first
      if log
        logger.info "  API Response: #{log.to_json}"
        render :json => log
      else # logs no more
        render :nothing => true, :status => :no_content
      end
    end
  end
end
