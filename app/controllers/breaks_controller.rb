class BreaksController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user,   only: [:new, :edit, :create, :update, :destroy]
  
  def new
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find_by(work_day: params[:date])
    @new_create_date = @attendance.work_day.strftime('%Y-%m-%d')
    @current_date = @attendance.work_day.strftime('%Y年%m月%d日')
    @break = @attendance.breaks.build
  end

  def create
    @user = User.find(params[:user_id])
    if params[:date].nil? || !valid_date_day?(params[:date])
      flash[:error] = "日付が無効です"
      render 'new'
      return
    else
      current_date = DateTime.parse(params[:date])
    end
    @new_create_date = current_date.strftime('%Y-%m-%d')
    @attendance = @user.attendances.find_by(work_day: params[:date])
    @break = @attendance.breaks.build(break_params)
    if @break.save
      flash[:success] = "休憩時間を登録しました"
      redirect_to user_attendance_day_path(@user, @attendance.work_day)
    else
      render 'new'
    end
  end

  def edit
    @break = Break.find(params[:id])
    @attendance = @break.attendance
    @user = User.find(@attendance.user_id) 
    @current_date = @attendance.work_day.strftime('%Y年%m月%d日')
    @new_create_date = @attendance.work_day.strftime('%Y-%m-%d')
  end

  def update
    @break = Break.find(params[:id])
    user_id = @break.attendance.user_id
    work_day = @break.attendance.work_day

    if @break.update(break_params)
      flash[:success] = "休憩時間を更新しました"
      redirect_to user_attendance_day_path(user_id, work_day)
    else
      render 'edit'
    end
  end

  def destroy
    @break = Break.find(params[:id])
    user_id = @break.attendance.user_id
    work_day = @break.attendance.work_day
    @break.destroy
    flash[:success] = "休憩時間を削除しました"
    redirect_to user_attendance_day_path(user_id, work_day)
  end

  def start
    @user = current_user
    @attendance = @user.attendances.find_by(work_day: Date.today)
  
    if !@attendance || !@attendance.start_time || @attendance.start_time > Time.current
      flash[:error] = "休憩を開始できません"
      redirect_to root_path
    elsif @attendance.breaks.where(end_time: nil).exists?
      flash[:error] = "すでに休憩中です"
      redirect_to root_path
    else
      @attendance.breaks.create(start_time: Time.current.strftime('%H:%M'))
      flash[:success] = "休憩を開始しました"
      redirect_to root_path
    end
  end
  
  # 休憩終了時間を登録するアクション
  def end
    @break = Break.find(params[:id])
  
    if !@break || @break.end_time
      flash[:error] = "休憩を終了できません"
      redirect_to root_path
    else
      @break.update(end_time: Time.current.strftime('%H:%M'))
      flash[:success] = "休憩を終了しました"
      redirect_to root_path
    end
  end
  
  private
    def break_params
      params.require(:break).permit(:start_time, :end_time)
    end

    def valid_date_day?(date)
      Date.valid_date?(*date.split('-').map(&:to_i))
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
      @user = User.find(params[:user_id])
      if !current_user.admin?
        redirect_to(root_url) unless current_user?(@user)
      end
    end

    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
