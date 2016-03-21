Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  
  namespace :admin do
    root "items#index"

    resources :items
    # TODO photos uploading
    
    resources :categories, only: [:new, :create, :show, :index]
    resources :users, only: [:index, :show] do
      collection do

        # TODO
        # 外界POST request
        # post "import_user", to: "users#import_user"
      end

      # member do
      #   get "/:uid", to: "users#check_user"
      # end
    end
    # get "users/show_uid/:uid", to: "users#show_uid", as: "uid_user"
    resources :counties, only: [:index, :show] do
      resources :towns, only: [:index, :show] do
        resources :roads, only: [:index, :show] do
          resources :stores, only: [:index, :show]
        end
      end
    end
    resources :orders, only: [:index, :show] do
      member do
        post "item_shipping"
        post "item_shipped"
        post "order_cancelled"
      end
    end
  end

  namespace :api do
    namespace :v1 do
      # TODO 重構整理
      # 分類API
      resources :categories, only: [:index, :show]

      # 商品API
      resources :items, only: [:index, :show]

      # 用戶API
      resources :users, only: [:create, :show, :update]

      # 訂單API
      resources :orders, only: [:create, :show, :index]

      # 超商API
      resources :counties, only: [:index, :show] do
        resources :towns, only: [:index, :show] do
          resources :roads, only: [:index, :show] do
            resources :stores, only: [:index, :show]
          end
        end
      end
    end
  end

  # namespace :store_api, defaults: { format: 'json' } do
  #   # /county_id/town_id/store_id

  #   # APP: request  county_id

  #   # WEB: response towns.json

  #   # APP: request town_id

  #   # WEB: response stores.json

  #   # get  /counties/towns.json

  #   # get "/counties/:county_id/towns", to: "counties#towns_response"
  #   resources :counties, only: [:index, :show] do
  #     resources :towns, only: [:index, :show] do
  #       resources :roads, only: [:index, :show] do
  #         resources :stores, only: [:index, :show]
  #       end
  #     end
  #   end
  # end
end