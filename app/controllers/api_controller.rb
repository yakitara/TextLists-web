class ApiController < ApplicationController
  before_filter :login_required
  skip_before_filter :set_lists
  
  def key
    if return_url = params[:r]
      redirect_to return_url + "?key=1234"
    else
      render :text => "Cannot redirect: r (URL to return) paramater is not supplied.", :status => 401
    end
  end
end
