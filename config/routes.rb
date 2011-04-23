Items::Application.routes.draw do
  root :to => "nav#index"
  get "/bookmarklet(.:format)", :to => "nav#bookmarklet", :as => "bookmarklet"
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
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
