Rails.application.routes.draw do
  root 'top_pages#home'
  get    '/signup', to: 'users#new'
  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :users do
    # usersリソースの下にルーティングを追加
    get '/attendance/today', to: redirect { |params, request| 
      "/users/#{params[:user_id]}/attendance/day/#{Date.today.strftime('%Y-%m-%d')}" 
    }
    get '/attendance/day/:date', to: 'attendances#show_by_day', as: :attendance_day
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
