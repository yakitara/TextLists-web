OpenID::REMOVED_RE = /
    # Comments
    <!--.*?-->
    # CDATA blocks
  | <!\[CDATA\[.*?\]\]>
    # script blocks
  | <script\b
    # make sure script is not an XML namespace
    (?!:)
    [^>]*>.*?<\/script>
  /mixun

class NavController < ApplicationController
  def index
    render :nothing => true, :layout => true
  end
  
  def login
  end

  def logout
    session.delete(:openid)
    redirect_to root_url
  end
  
  def openid
    if resp = request.env["rack.openid.response"]
      if resp.status == :success
        session[:openid] = resp.display_identifier
        # FIXME: thing the case that credential is, but user isn't
        unless credential = Credential.find_by_identifier(session[:openid])
          Credential.transaction do
            credential = Credential.create!(:identifier => session[:openid], :user => User.create!)
          end
        end
        redirect_to root_path
      else
        flash[:error] = "Error: #{resp.status}"
        redirect_to login_path
      end
    else
      headers['WWW-Authenticate'] = Rack::OpenID.build_header(
        :identifier => params["identifier"]
        )
      render :nothing => true, :status => 401
    end
  end
  
  def bookmarklet
  end
end
