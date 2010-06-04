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
    json = [List, Item, Listing].inject({}) do |h, klass|
      h.update(klass.table_name => klass.all)
    end.to_json
    render :json => json
    # render :text => '{"items":[{"id":1,"content":"new sync item","updated_at":"2010-05-20 01:02:30 +0900","created_at":"2010-05-20 01:02:30 +0900"}],"lists":[{"id":1,"name":"new sync list","updated_at":"2010-05-20 01:02:30 +0900","created_at":"2010-05-20 01:02:30 +0900"}],"listings":[{"id":1,"item_id":1,"list_id":1,"updated_at":"2010-05-20 01:02:30 +0900","created_at":"2010-05-20 01:02:30 +0900"}]}'
  end
end
