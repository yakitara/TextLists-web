Items::Application.routes.draw do |map|
  root :to => "nav#index"
  match "/bookmarklet(.:format)", :to => "nav#bookmarklet", :via => :get, :as => "bookmarklet"
#  match "/api/items", :to => "items#bookmark", :via => :post, :as => "bookmark"
  match "/login", :to => "nav#login", :via => :get, :as => "login"
  match "/openid", :to => "nav#openid", :via => :post, :as => "openid"
  match "/logout", :to => "nav#logout", :via => :delete, :as => "logout"
  
  resources :items, :only => [:new, :create]
  
  #match %r|/lists/:id$|, :to => redirect("/lists/%{id}/items"), :as => :list
  
  resources :lists, :only => [:show, :new, :update, :create, :destroy] do
    collection do
      post :sort
    end
    resources :items, :only => [:index, :show, :new, :create, :update] do
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

  namespace :api do
    match "key", :to => "api#key", :via => :get, :as => "api_key"
    match "changes", :to => "api#changes", :via => :get, :as => "api_changes"
    resources :items, :only => [:create]
    match "in-box/items(.:format)", :to => "items#create", :via => :post, :as => "inbox_items", :defaults => {:list => "in-box"}
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
