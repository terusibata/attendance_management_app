Rails.application.routes.draw do
  root 'top_pages#home'
  get    '/now_user_attendances', to: 'top_pages#now_user_attendances', as: :now_user_attendances
  get    '/signup', to: 'users#new'
  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :users do
    # usersリソースの下にルーティングを追加
    # attendance/dayのルーティング
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

    # attendance/monthのルーティング
    get '/attendance/thismonth', to: redirect { |params, request|
      "/users/#{params[:user_id]}/attendance/month/#{Date.today.strftime('%Y-%m')}"
    }
    get '/attendance/month/:month', to: 'attendances#show_by_month', as: :attendance_month

    # breakのルーティング
    get '/attendance/day/:date/break/new', to: 'breaks#new', as: :new_break
    post '/attendance/day/:date/break/new', to: 'breaks#create', as: :create_break
    get '/break/edit/:id', to: 'breaks#edit', as: :edit_break
    patch '/break/edit/:id', to: 'breaks#update', as: :update_break
    delete '/break/edit/:id', to: 'breaks#destroy', as: :delete_break
  end

  # 出退勤、休憩時間を登録する
  post '/attendance/start', to: 'attendances#start', as: :start_attendance
  post '/attendance/end', to: 'attendances#end', as: :end_attendance
  post '/break/start', to: 'breaks#start', as: :start_break
  post '/break/:id/end', to: 'breaks#end', as: :end_break

  # 管理者用：従業員全員の勤怠情報を表示する
  get '/admin/attendance/today', to: redirect { |params, request|
    "/admin/attendance/day/#{Date.today.strftime('%Y-%m-%d')}"
  }
  get '/admin/attendance/day/:date', to: 'attendances#show_admin_by_day', as: :admin_attendance_day
  get '/admin/attendance/thismonth', to: redirect { |params, request|
    "/admin/attendance/month/#{Date.today.strftime('%Y-%m')}"
  }
  get '/admin/attendance/month/:month', to: 'attendances#show_admin_by_month', as: :admin_attendance_month

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
