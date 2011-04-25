TextLists-web
=============

Notes for Developers
--------------------
=== Create config/initializers/secret_token.rb
    echo Rails.application.config.secret_token = \"$(rake -s secret)\" > config/initializers/secret_token.rb
