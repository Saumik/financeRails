FinanceRails2::Application.routes.draw do
  get "mobile/index"
  post "mobile/sync"

  devise_for :users

  get "budget/index"

  get "report/month_expenses"
  post "report/month_expenses"

  get "external/import"
  get "external/import_json"
  get "external/export_json"
  get "external/download_backup/:folder_name" => 'external#download_backup'
  post "external/process_confirm_import"
  post 'external/do_import'

  post 'users/login' => 'users#login'
  get 'users/my_profile' => 'users#my_profile'
  put 'users/update_profile' => 'users#update_profile'

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
  # Note: This route will make all actions in every controller accessible via GET requests
  # match ':controller(/:action(/:id(.:format)))'

  resources :accounts do
    member do
      post :fetch
    end
  end

  resources :line_items do
    collection do
      get :autocomplete_payee
      get :autocomplete_category
      get :get_line_items_data_table
      get :get_category_for_payee
      get :mass_rename
      get :search_overlay
      post :mass_rename
    end
    member do
      get :split
      post :perform_split
    end
  end

  resources :payee do
    collection do
      post :add_processing_rule
      get :run_processing_rule
      get :delete_processing_rule
      post :rename_payee
    end
  end

  resources :budget_items, path: 'budgets', controller: 'budgets' do
    collection do
      get :expense_summary
    end
    member do
      get :clone
    end
  end

  resources :groceries, :as => :grocery_line_items do
    collection do
      get :report
    end
  end

  root :to => redirect("/line_items")
end
