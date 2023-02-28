Rails.application.routes.draw do
  root 'top_pages#home'
  get    '/signup', to: 'users#new'
  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :users do
    # usersリソースの下にルーティングを追加
    get '/attendance/day', to: 'attendances#show_by_day'
    get '/attendance/day/:date', to: 'attendances#show_by_day'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
