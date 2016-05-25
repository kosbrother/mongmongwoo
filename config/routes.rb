Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'

  root 'pages#index'
  get  "/auth/:provider/callback" => "sessions#create", as: "login"
  get '/auth/:provider', to: lambda{|env| [404, {}, ["Not Found"]]}, as: 'auth'
  get  "/signout" => "sessions#destroy", as: "signout"

  resources :categories, only: [:show] do
    resources :items, only: [:show]
  end

  get "/checkout", to: "carts#checkout", as: "checkout"
  get "/cart_info", to: "carts#info", as: "cart_info"
  get "/select_store", to: "carts#select_store", as: "select_store"
  post "/store_reply", to: "carts#info", as: "store_reply"
  post "/confirm_cart", to: "carts#confirm", as: "confirm_cart"
  get "/confirm_cart", to: "carts#confirm"
  post "/submit_order", to: "carts#submit", as: "submit_order"
  get "/success", to: "carts#success", as: "success"

  resources :cart_items, only: [:create, :destroy] do
    member do
      patch "update_quantity"
      patch "update_spec"
    end
  end

  resources :orders, only: [:index, :show]
  resources :favorite_items, only: [:index] do
    member do
      get :favorite
      get :remove
    end

  end
  # 助理後台
  namespace :staff do
    root "categories#index"
    get "/signin", to: "sessions#new"
    post "/signin", to: "sessions#create"
    delete "/signout", to: "sessions#destroy"

    resources :categories, only: [:show, :index]

    resources :items do
      resources :photos, except: [:show]

      resources :item_specs, except: [:show]
    end
  end

  resources :allpay, only:[] do
    collection do
      post "/create/:order_id", to: "allpay#create", as: "create"
      post "status_update"
      post "create_reply"
    end
  end

  # 管理員後台
  namespace :admin do
    root "categories#index"
    get "/signin", to: "sessions#new"
    post "/signin", to: "sessions#create"
    delete "/signout", to: "sessions#destroy"

    resources :items do
      collection do
        get "search"
      end

      member do
        patch "on_shelf"
        patch "off_shelf"
      end

      resources :photos, except: [:show]

      resources :item_specs, except: [:show] do
        member do
          patch "on_shelf"
          patch "off_shelf"
        end
      end
    end

    resources :categories, only: [:new, :create, :show, :index] do
      # 商品重新排序
      collection do
        post "sort_items_priority"
      end
    end

    resources :users, only: [:index, :show, :create, :update] do
      collection do
        # 外界POST request
        post "import_user", to: "users#import_user"
      end
    end

    get "users/show_uid/:uid", to: "users#show_uid", as: "uid_user"

    resources :counties, only: [:index, :show] do
      resources :towns, only: [:index, :show] do
        resources :roads, only: [:index, :show] do
          resources :stores, only: [:index, :show]
        end
      end
    end

    resources :orders, only: [:index, :show, :update] do
      collection do
        get "exporting_files"
        get "status_index"
      end

      member do
        patch "update_status"
      end
    end

    # 註冊裝置
    resources :device_registrations, only: [:index, :show]

    # 推播訊息
    resources :notifications, only: [:index, :show, :new, :create]

    # 銷售統計
    resources :sales_reports, only: [:index] do
      collection do
        get "item_sales_result"
        get "item_revenue_result"
        get "cost_statistics_index"
        post "/cost_statistics_index", to: "sales_reports#cost_statistics_create"
        get "sales_income_result"
      end
    end

    resources :taobao_suppliers, only: [:index, :new, :create, :edit, :update, :destroy]
  end

  # API for App
  get 'api/android_version' => 'api#android_version'
  namespace :api do
    namespace :v1 do
      # 分類API
      resources :categories, only: [:index, :show]

      # 商品API
      resources :items, only: [:index, :show] do
        member do
          # 商品樣式資料
          get "spec_info"
        end
      end

      # 用戶API
      resources :users, only: [:create, :show, :update]

      # 訂單API
      resources :orders, only: [:create, :show, :index] do
        collection do
          get "/user_owned_orders/:uid" => "orders#user_owned_orders"
          get "by_email_phone"
        end
      end

      # 超商API
      resources :counties, only: [:index, :show] do
        resources :towns, only: [:index, :show] do
          resources :roads, only: [:index, :show] do
            resources :stores, only: [:index, :show]
          end
        end
      end

      # 註冊裝置
      resources :device_registrations, only: [:create]
    end

    namespace :v2 do
      # 訂單API
      resources :orders, only: [:show, :index] do
        collection do
          get "/user_owned_orders/:uid" => "orders#user_owned_orders"
        end
      end
    end
  end
end
