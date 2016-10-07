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
  get '/search_items', to: "searchs#search_items"
  get '/catalog', to: "items#catalog"

  resources :categories, only: [:show] do
    resources :items, only: [:show]
  end

  patch "/toggle_shopping_point", to: "carts#toggle_shopping_point"
  get "/checkout", to: "carts#checkout", as: "checkout"
  get "/cart_info", to: "carts#info", as: "cart_info"
  get "/select_store", to: "carts#select_store", as: "select_store"
  patch "/update_ship_type", to: "carts#update_ship_type", as: "update_ship_type"
  get "/get_towns", to: "carts#get_towns", as: "get_towns"
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
  resources :favorite_items, only: [:index, :destroy] do
    member do
      get :toggle_favorite
    end
  end

  resources :wish_lists, only: [] do
    member do
      get :toggle_wish
    end
  end

  resources :shopping_point_campaigns, only: [:index]
  resources :shopping_points, only: [:index]
  resources :wish_lists, only: [:index, :destroy]
  resources :my_messages, only: [:index]

  resources :allpay, only:[] do
    collection do
      post "create_from_processing", as: "create"
      post "/post_order_to_allpay/:order_id", to: "allpay#post_order_to_allpay", as: "post_order_to_allpay"
      post "status_update"
      post "create_reply"
      get "/barcode/:order_id", to: "allpay#barcode", as: "barcode"
    end
  end

  resources :pay2go, only:[] do
    collection do
      post "notify"
      post "return"
    end
  end

  namespace :admin do
    root "pages#home"
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
        delete 'delete_all'
      end
      member do
        patch "update_quantity"
        patch "update_spec"
        patch "update_actual_quantity"
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

    resources :stocks, only: [:index, :edit]

    resources :stock_specs, only: [:create, :update]

    resources :items, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
      collection do
        get "search"
      end

      member do
        get "specs"
        patch "on_shelf"
        patch "off_shelf"
        patch "update_initial_on_shelf_date"
      end

      resources :photos, only: [:index, :new, :create, :edit, :update, :destroy] do
        collection do
          post "photo_sort"
        end
      end

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

    resources :categories do
      member do
        get "subcategory"
      end
      collection do
        post "import_excel"
      end
    end

    resources :tags

    resources :users, only: [:index, :show, :create, :update] do
      collection do
        post "import_user"
        get "search"
        get "export_user_list"
      end
      resources :my_messages, only: [:index, :new, :create]
      resources :shopping_points, only: [:index, :new, :create] do
        collection do
          get "render_select_form"
        end
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

    resources :orders, only: [:index, :show, :edit, :update] do
      collection do
        get "exporting_files"
        get "status_index"
        get "search"
        get "change_status_to_transfer"
        get "export_processing_order_list"
        get "open_barcode_tab"
        get "export_returned_order_list"
        patch "update_to_processing"
        get "export_home_delivery_order_list"
      end

      member do
        patch "update_status"
        patch "restock"
        get "export_changed_order"
      end
    end

    resources :order_items, only: [:destroy]

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
    resources :banners, only: [:index, :new, :create, :destroy] do
      collection do
        get "render_select_form"
      end
    end

    resources :shop_infos, except: [:show]
    resources :shopping_point_campaigns
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
        resources :orders, only: [] do
          member do
            patch "cancel"
          end
        end
      end

      resources :categories, only: [:index] do
        member do
          get "subcategory"
        end

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
      resources :orders, only: [:create, :show] do
        collection do
          post "checkout"
          post "check_pickup_record"
          get "by_user_email"
          get "by_email_phone"
        end
      end
      resources :banners, only: [:index]
      resources :oauth_sessions, only: [:create]
      resources :mmw_registrations, only: [:create] do
        collection do
          post "login"
        end
      end

      resources :users, only: [] do
        resources :my_messages, only: [:index]
        resources :shopping_points, only: [:index]
        resources :shopping_point_campaigns, only: [:index]
      end

      resources :categories, only: [:index]
    end
  end
end
