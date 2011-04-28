# http://edgeguides.rubyonrails.org/routing.html
Items::Application.routes.draw do
  root :to => "nav#index"
  get "/bookmarklet(.:format)", :to => "nav#bookmarklet", :as => "bookmarklet"
  get "/bookmark/new", :to => "nav#bookmark", :as => "new_bookmark"
  get "/login", :to => "nav#login", :as => "login"
  get "/oauth", :to => "nav#oauth", :as => "oauth"
  delete "/logout", :to => "nav#logout", :as => "logout"
  
  resources :items, :only => [:create, :update] do
    collection do
      get :done
    end
    resources :listings, :only => [] do
      member do
        put :undone
      end
    end
  end
  
  resources :lists, :only => [:show, :new, :update, :create, :destroy] do
    collection do
      post :sort
    end
    resources :items, :only => [:index, :create, :update] do
      collection do
        post :sort
      end
      resources :listings, :only => [:destroy] do
        collection do
          post :move
        end
      end
    end
  end
  
  # old api
  get "/api/key", :to => "api#key", :as => "api_key", :format => false
  get "/api/changes/next(/:id)", :to => "api/change_logs#next", :as => "api_next_change", :format => false
  namespace :api, :format => false do
    resources :items, :only => [:create, :show, :update]
    post "in-box/items", :to => "items#create", :as => "inbox_items", :defaults => {:list => "in-box"}
    resources :lists, :only => [:create, :show, :update]
    resources :listings, :only => [:create, :show, :update]
#    resources :changes, :controller => "change_logs", :only => [:create]
  end
  
  # new versioned api
  scope "/api(/:version)", :module => "api", :as => "api", :version => %r"[^/]+", :format => false do
    resources :changes, :controller => "change_logs", :only => [:create] do
      get "next/:limit", :to => "change_logs#next", :as => "next"
    end
  end
end
