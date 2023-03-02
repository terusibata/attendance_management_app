class UsersController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user,   only: [:show, :edit, :update]
  before_action :admin_user,     only: [:destroy, :new, :create]

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show
    @user = User.find(params[:id])
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "ユーザーを登録しました"
      redirect_to @user
    else
      render 'new'
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "プロフィールを更新しました"
      redirect_to @user
    else
      render 'edit'
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "削除に成功しました"
    redirect_to users_url
  end

  private
    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :hire_date, :end_date, :admin)
    end

    # ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:error] = "ログインしてください"
        redirect_to login_url
      end
    end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      if !current_user.admin?
        redirect_to(root_url) unless current_user?(@user)
      end
    end

    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
