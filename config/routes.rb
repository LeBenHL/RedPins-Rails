RedPins::Application.routes.draw do

  resources :bookmarks


  resources :comments


  resources :likes


  match '/users/login' => 'Users#login', :via => :post
  match '/users/add' => 'Users#add', :via => :post
  match '/users/likeEvent' => 'Users#likeEvent', :via => :post
  match '/users/removeLike' => 'Users#removeLike', :via => :post
  match '/users/alreadyLikedEvent' => 'Users#likeEvent?', :via => :post
  match '/users/postComment' => 'Users#postComment', :via => :post
  match '/users/deleteEvent' => 'Users#deleteEvent', :via => :post
  match '/users/cancelEvent' => 'Users#cancelEvent', :via => :post
  match '/users/restoreEvent' => 'Users#restoreEvent', :via => :post
  match '/users/bookmarkEvent' => 'Users#bookmarkEvent', :via => :post
  match '/events/search' =>  'Events#search', :via => :post   #TODO REMOVE LATER WHEN WE GET CONTACT W/ JERRY CODE
  match '/events/getRatings' => 'Events#getRatings', :via => :post
  match '/events/getComments' => 'Events#getComments', :via => :post
  match '/events/getEvent' => 'Events#getEvent', :via => :post
  match '/events/add' => 'Events#add', :via => :post

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
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
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
  #       get 'recent', :on => :collection
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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
