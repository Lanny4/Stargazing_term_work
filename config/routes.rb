Rails.application.routes.draw do
  root "pages#home"
  resources :products, only: [:index, :show] do
    resources :reviews, only: [:create]
  end
  resource :registration, only: [:new, :create]
  resource :session, only: [:new, :create, :destroy]
  get "/cart", to: "cart#show", as: :cart
  post "/cart/items", to: "cart#add", as: :cart_items
  patch "/cart/items/:product_id", to: "cart#update", as: :cart_item
  delete "/cart/items/:product_id", to: "cart#remove", as: :remove_cart_item
  get "/favorites", to: "favorites#index", as: :favorites
  post "/favorites/:product_id", to: "favorites#toggle", as: :toggle_favorite
  resource :checkout, only: [:new, :create]
  resources :orders, only: [:index, :show] do
    post :pay_demo, on: :member
  end
  resources :contact_messages, only: [:new, :create]
  get "/about", to: "pages#about", as: :about
  get "/delivery", to: "pages#delivery", as: :delivery

  namespace :admin do
    root "dashboard#index"
    resources :products, except: [:show]
    resources :orders, only: [:index, :show, :update]
    resources :contact_messages, only: [:index, :show]
  end
end
