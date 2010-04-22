class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter do
    if openid = session[:openid]
      @current_user = User.joins(:credentials).where("credentials.identifier" => openid).first
    end
    
    selects = "lists.id, lists.name, lists.position" # for PostgreSQL
    @lists = List.joins("LEFT JOIN listings ON listings.list_id = lists.id").group(selects)
    @lists = @lists.where(:user_id => current_user.try(:id))
    @lists = @lists.order("lists.position ASC").all(:select => "#{selects}, COUNT(listings.id) AS item_count")
  end
  
  #= about authorization
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
end
