class ApiController < ApplicationController
  before_filter :login_required, :only => [:key]
  before_filter :api_key_required, :except => [:key]
  skip_before_filter :set_lists
  
  def key
    if return_url = params[:r]
      #FIXME: return user specific unique key
      key = calculate_api_key(current_user.salt, "*", "*")
      redirect_to return_url + "?user_id=#{current_user.id}&key=#{key}"
    else
      render :text => "Cannot redirect: r (URL to return) paramater is not supplied.", :status => 401
    end
  end
  
  def changes
    serializable = [List, Item, Listing].inject({}) do |h, klass|
      h.update(klass.table_name => klass.select("id, updated_at").all)
    end
    render :json => serializable
  end
end
