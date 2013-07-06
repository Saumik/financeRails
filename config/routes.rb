FinanceRails2::Application.routes.draw do
  resources :planned_items

  get "investment/" => 'investment#index'

  #get "mobile/index"
  #post "mobile/sync"

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

  resources :accounts do
    member do
      post :fetch
    end
  end

  resources :line_items do
    collection do
      get :category_names
      get :payee_names
      get :payee_data
      get :mass_rename
      get :search_overlay
      post :mass_rename
      post :ignore_rename
      post :cache_refresh
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

  resources :investment_plan do
  end

  resources :investment_line_items do

  end

  resources :investment_allocation_plans do

  end

  resources :investment_assets do

  end

  root :to => 'pages#index'
end
