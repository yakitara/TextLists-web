TextLists-web
=============

Notes for Developers
--------------------
### Create config/initializers/secret_token.rb

    echo Rails.application.config.secret_token = \"$(rake -s secret)\" > config/initializers/secret_token.rb


### Create config/initializers/oauth_consumer_secret.rb
Register as you own app at https://dev.twitter.com/apps.

    Rails.application.config.oauth = {
      :consumer_key => "#{secret}",
      :consumer_secret => "#{secret}",
      :oauth_callback => "http://localhost:3000/oauth",
    }


Production Environment
-----------------------
After `cap deploy:update_code` #{deploy_to}/shared/config/initializers/*r.b will be copied to #{latest_release}/config/initializers.
Place those secret initializers files for production at #{deploy_to}/shared/config/initializers/

### Create ${deploy_to}shared/config/initializers/hoptoad.rb

    HoptoadNotifier.configure do |config|
      config.api_key = "#{Hoptaod API key}"
    end
