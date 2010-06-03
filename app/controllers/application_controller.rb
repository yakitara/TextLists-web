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
    selects = "lists.id, lists.name, lists.position, lists.created_at" # for PostgreSQL
    @lists = List.joins("LEFT JOIN listings ON listings.list_id = lists.id").group(selects)
    @lists = @lists.where(:user_id => current_user.try(:id))
    @lists = @lists.order("lists.position ASC, lists.created_at ASC").all(:select => "#{selects}, COUNT(listings.id) AS item_count")
  end
  
  #= authorization
  attr_reader :current_user
  def current_user?
    current_user.present?
  end
  helper_method :current_user, :current_user?
  
  def login_required
    unless current_user?
      redirect_to login_path
      false
    end
  end

  #= authentication
  def calculate_api_key(salt, path=self.controller_path, action=self.action_name)
    require "digest/sha2"
    Digest::SHA2.hexdigest("#{salt}-#{path}#{action}")
  end
  helper_method :calculate_api_key
  
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
