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
    # TODO: refactoring. move the logic into the model. and consider how to be DRY those codes...
    if next_log = ChangeLog.where("id > ?", params[:id].to_i).first
      # 2010-07-13: Merging newer log will cause unknwon list_id of listings on the client synchronizing
#       @logs = ChangeLog.where("record_type = ? AND record_id = ? AND changed_at >= ? AND id != ?", next_log.record_type, next_log.record_id, next_log.changed_at, next_log.id).order("changed_at ASC").all
#       change = ActiveSupport::JSON.decode(next_log.json)
#       @logs.each do |log|
#         change.update(ActiveSupport::JSON.decode(log.json))
#       end
#       next_log.json = change.merge(change){|k, v| v.as_json }.to_json
      logger.info "  API Response: #{next_log.to_json}"
      render :json => next_log
    else # logs no more
      render :nothing => true, :status => :no_content
    end
  end
end
