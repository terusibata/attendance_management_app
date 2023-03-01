Rails.application.routes.draw do
  root 'top_pages#home'
  get    '/signup', to: 'users#new'
  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :users do
    # usersリソースの下にルーティングを追加
    # attendanceのルーティング
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
    # breakのルーティング
    get '/attendance/day/:date/break/new', to: 'breaks#new', as: :new_break
    post '/attendance/day/:date/break/new', to: 'breaks#create', as: :create_break
  end
  get '/break/edit/:id', to: 'breaks#edit', as: :edit_break
  patch '/break/edit/:id', to: 'breaks#update', as: :update_break
  delete '/break/edit/:id', to: 'breaks#destroy', as: :delete_break
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
