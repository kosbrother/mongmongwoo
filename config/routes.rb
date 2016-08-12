Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  root 'pages#index'
  get  "/auth/:provider/callback" => "sessions#login_by_auth", as: "login_by_auth"
  get '/auth/:provider', to: lambda{|env| [404, {}, ["Not Found"]]}, as: 'auth'
  get  "/signout" => "sessions#destroy", as: "signout"
  post "/login" => "sessions#login_by_mmw", as: "login_by_mmw"
  post "/register" => "users#create", as: "register"
  post "/forget" => "users#sent_reset_email"
  get '/shop_infos' => "pages#shop_infos"

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
  get "/password_resets/edit", to: "password_resets#edit"
  put "/password_resets/update", to: "password_resets#update"
  get "/password_resets/success", to: "password_resets#success"

  resources :cart_items, only: [:create, :destroy] do
    member do
      patch "update_quantity"
      patch "update_spec"
    end
  end

  resources :orders, only: [:index, :show] do
    member do
      patch "cancel"
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

    resources :items, only: [:new, :create, :show, :edit, :update, :destroy] do
      resources :photos, except: [:show]

      resources :item_specs, except: [:show]
    end
  end

  resources :allpay, only:[] do
    collection do
      post "create_from_processing", as: "create"
      post "status_update"
      post "create_reply"
      get "/barcode/:order_id", to: "allpay#barcode", as: "barcode"
    end
  end

  # 管理員後台
  namespace :admin do
    root "orders#status_index"
    get "/signin", to: "sessions#new"
    post "/signin", to: "sessions#create"
    delete "/signout", to: "sessions#destroy"

    resources :admin_carts, only: [] do
      collection do
        get "checkout"
        post "submit"
      end

      member do
        patch "note"
      end
    end

    resources :roads, only: [] do
      collection do
        get "get_road_options"
      end
    end

    resources :stores, only: [:index, :new, :create, :edit, :update, :destroy] do
      collection do
        get "get_store_options"
      end
    end

    resources :admin_cart_items, only: [:create, :destroy] do
      collection do
        post "add"
        post "get_by_id"
        post "import_excel"
      end
      member do
        patch "update_quantity"
        patch "update_spec"
      end
    end

    resources :confirm_carts, only: [:index] do
      member do
        post "confirm"
      end

      collection do
        get "export_shipping_list"
      end
    end

    resources :stocks, only: [:index] do
      collection do
        get "/:taobao_supplier_id/stock_lists", to: "stocks#stock_lists", as: "stock_lists"
        get "anoymous_supplier_stocks"
      end
    end

    resources :stock_specs, only: [:update]

    resources :items, only: [:new, :create, :show, :edit, :update, :destroy] do
      collection do
        get "search"
      end

      member do
        get "specs"
        patch "on_shelf"
        patch "off_shelf"
      end

      resources :photos, except: [:show]

      resources :item_specs, only: [:new, :create, :edit, :update] do
        member do
          patch "on_shelf"
          patch "off_shelf"
          patch "stop_recommend"
          patch "start_recommend"
          get "style_pic"
        end
      end
    end

    resources :categories, only: [:new, :create, :show, :index, :edit, :update, :destroy] do
      collection do
        post "sort_items_priority"
      end
    end

    resources :users, only: [:index, :show, :create, :update] do
      collection do
        post "import_user"
        get "search"
        get "export_user_list"
      end
      resources :my_messages, only: [:index, :new, :create]
    end

    get "users/show_uid/:uid", to: "users#show_uid", as: "uid_user"

    resources :counties, only: [:index, :show] do
      resources :towns, only: [:index, :show] do
        resources :roads, only: [:index, :show] do
          resources :stores, only: [:index, :show]
        end
      end
    end

    resources :orders, only: [:index, :show, :edit, :update] do
      collection do
        get "exporting_files"
        get "status_index"
        get "search"
        get "export_processing_order_list"
        get "export_returned_order_list"
        patch "update_to_processing"
      end

      member do
        patch "update_status"
        get "select_orders"
        post "combine_orders"
        patch "restock"
      end
    end

    # 註冊裝置
    resources :device_registrations, only: [:index, :show]

    # 推播訊息
    resources :notifications, only: [:index, :show, :new, :create, :destroy] do
      collection do
        get :get_items
      end
    end

    # 銷售統計
    resources :sales_reports, only: [:index] do
      collection do
        get "item_sales_result"
        get "item_revenue_result"
        get "cost_statistics_index"
        post "/cost_statistics_index", to: "sales_reports#cost_statistics_create"
        get "sales_income_result"
        get "export_item_sales_result"
      end
    end

    resources :taobao_suppliers, only: [:index, :new, :create, :edit, :update, :destroy, :show] do
      member do
        get "items"
      end
    end

    resources :mail_records, only: [] do
      collection do
        patch "/sending_survey_email/:order_id/", to: "mail_records#sending_survey_email", as: "sending_survey_email"
      end
    end

    resources :messages, only: [:index, :new, :create, :show, :destroy]
    resources :promotions, only: [:index, :new, :create, :destroy]
    resources :shop_infos, except: [:edit, :update]
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

    namespace :v3 do
      get '/search_items', to: "search#search_items"
      get '/item_names', to: "search#item_names"
      get '/hot_keywords', to: "search#hot_keywords"

      resources :counties, only: [:index] do
        resources :towns, only: [:index] do
          resources :roads, only: [:index] do
            resources :stores, only: [:index]
          end
        end
      end

      resources :users, only: [:create] do
        resources :my_messages, only: [:index]
        resources :favorite_items, only: [:index, :create] do
          collection do
            delete 'items/:item_id' => 'favorite_items#destroy'
          end
        end
        resources :wish_lists, only: [:index, :create] do
          collection do
            delete 'item_specs/:item_spec_id' => 'wish_lists#destroy'
          end
        end
        resources :shopping_points, only: [:index]
        resources :orders do
          member do
            patch "cancel"
          end
        end
      end

      resources :categories, only: [:index] do
        resources :items, only: [:index, :show]
      end

      resources :device_registrations, only: [:create]
      resources :orders, only: [:create, :show] do
        collection do
          get "/user_owned_orders/:uid" => "orders#user_owned_orders"
          get "by_user_email"
          get "by_email_phone"
        end
      end

      resources :messages, only: [:index, :show]
      resources :mmw_registrations, only: [:create] do
        collection do
          post "login"
          post "forget"
        end
      end

      resources :oauth_sessions, only: [:create]
      resources :shop_infos, only: [:index]
    end

    namespace :v4 do
      resources :orders, only: [:create]
    end
  end
end
