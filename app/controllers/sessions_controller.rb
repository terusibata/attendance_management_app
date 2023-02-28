class SessionsController < ApplicationController
  # ログイン済みの場合はhomeにリダイレクト
  before_action :logged_in_user, only: [:new]

  def new
    if logged_in?
      redirect_to root_path
    end
  end

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      redirect_to user
    else
      flash.now[:error] = 'メールアドレスまたはパスワードが間違っています'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end

  private
    # ログイン済みユーザーかどうか確認
    def logged_in_user
      if logged_in?
        flash[:error] = "すでにログインしています"
        redirect_to root_path
      end
    end
end
