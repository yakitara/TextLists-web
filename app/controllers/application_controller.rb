class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_current_user
  def set_current_user
    if openid = session[:openid]
      @current_user = User.joins(:credentials).where("credentials.identifier" => openid).first
    end
  end
  before_filter :set_lists
  def set_lists
    List.with_user_scope(current_user) do
      selects = "lists.id, lists.name, lists.position, lists.created_at" # for PostgreSQL
      @lists = List.joins("LEFT JOIN listings AS lg ON lg.list_id = lists.id AND lg.deleted_at IS NULL").group(selects)
      @lists = @lists.order("lists.position ASC, lists.created_at ASC").all(:select => "#{selects}, COUNT(lg.id) AS item_count")
    end
  end
  
  #= authorization
  attr_reader :current_user
  def current_user?
    current_user.present?
  end
  helper_method :current_user, :current_user?
  
  def login_required
    unless current_user?
      redirect_to login_path(:return_to => request.url)
      false
    end
  end

  #= authentication and authorization
  module Auth
    def self.included(base)
      base.helper_method :calculate_api_key if base.respond_to?(:helper_method)
    end
    
    def calculate_api_key(salt, path=self.controller_path, action=self.action_name)
      require "digest/sha2"
      Digest::SHA2.hexdigest("#{salt}-#{path}#{action}")
    end
    
    def api_key_required
      if user = User.find_by_id(params[:user_id])
        if params[:key] == calculate_api_key(user.salt)
          @current_user = user
        elsif params[:key] == calculate_api_key(user.salt, "*", "*")
          @current_user = user
        end
      end
      unless @current_user
        render :nothing => true, :status => 403
        false
      end
    end
  end
  include Auth
end
