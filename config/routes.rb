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

    get '/attendance/new/today', to: redirect { |params, request|
      "/users/#{params[:user_id]}/attendance/new/#{Date.today.strftime('%Y-%m-%d')}"
    }
    get '/attendance/new/:date', to: 'attendances#new', as: :new_attendance
    post '/attendance/new/:date', to: 'attendances#create', as: :create_attendance

    get '/attendance/edit/today', to: redirect { |params, request|
      "/users/#{params[:user_id]}/attendance/edit/#{Date.today.strftime('%Y-%m-%d')}"
    }
    get '/attendance/edit/:date', to: 'attendances#edit', as: :edit_attendance
    patch '/attendance/edit/:date', to: 'attendances#update', as: :update_attendance
    delete '/attendance/edit/:date', to: 'attendances#destroy', as: :delete_attendance
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
