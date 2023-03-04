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
      render 'breaks/new'
      return
    else
      current_date = Time.parse(params[:date])
    end
    @new_create_date = current_date.strftime('%Y-%m-%d')
    @current_date = current_date.strftime('%Y年%m月%d日')
    @attendance = @user.attendances.find_by(work_day: params[:date])
    @break = @attendance.breaks.build(break_params)

    if @attendance.nil?
      flash[:error] = "日付に対応する勤怠がありません"
      render 'breaks/new'
      return
    end

    if @break.start_time.nil?
      flash[:error] = "開始時間が無効です"
      render 'breaks/new'
      return
    end

    if @break.end_time.nil?
      flash[:error] = "終了時間が無効です"
      render 'breaks/new'
      return
    end

    if @break.start_time > @break.end_time
      flash[:error] = "開始時間が終了時間よりも前です"
      render 'breaks/new'
      return
    end

    if @attendance.breaks.where(end_time: nil).exists? || @attendance.breaks.where(start_time: nil).exists?
      flash[:error] = "出退勤時間が無効です"
      render 'breaks/new'
      return
    end

    if @attendance.start_time > @break.start_time
      flash[:error] = "出勤時間が開始時間よりも前です"
      render 'breaks/new'
      return
    end

    if @attendance.end_time < @break.end_time
      flash[:error] = "退勤時間が終了時間よりも前です"
      render 'breaks/new'
      return
    end

    start_time = Time.parse(check_break_params[:start_time]).strftime('%H:%M:%S')
    end_time = Time.parse(check_break_params[:end_time]).strftime('%H:%M:%S')

    # 休憩時間の重複チェック
    @attendance.breaks.where.not(id: @break.id).each do |break_time|
      if (break_time.start_time.strftime('%H:%M:%S')..break_time.end_time.strftime('%H:%M:%S')).cover?(start_time) || (break_time.start_time.strftime('%H:%M:%S')..break_time.end_time.strftime('%H:%M:%S')).cover?(end_time)
        flash[:error] = "休憩時間が重複しています"
        render 'breaks/new'
        return
      end
    end

    if @break.save
      flash[:success] = "休憩時間を登録しました"
      redirect_to user_attendance_day_path(@user, @attendance.work_day)
    else
      render 'breaks/new'
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
    @attendance = @break.attendance
    @user = User.find(@attendance.user_id) 
    user_id = @break.attendance.user_id
    work_day = @break.attendance.work_day

    @current_date = @attendance.work_day.strftime('%Y年%m月%d日')
    @new_create_date = @attendance.work_day.strftime('%Y-%m-%d')

    # 入力値のチェック
    begin
      start_time = Time.parse(check_break_params[:start_time]).strftime('%H:%M:%S')
      end_time = Time.parse(check_break_params[:end_time]).strftime('%H:%M:%S')
    rescue ArgumentError
      flash[:error] = "休憩時間が無効です"
      render 'breaks/edit'
      return
    end

    puts start_time
    puts end_time
    puts @attendance.start_time
    puts @attendance.end_time

    if @attendance.start_time.strftime('%H:%M:%S') > start_time
      flash[:error] = "出勤時間が開始時間よりも前です"
      render 'breaks/edit'
      return
    end

    if @attendance.end_time.strftime('%H:%M:%S') < end_time
      flash[:error] = "退勤時間が終了時間よりも前です"
      render 'breaks/edit'
      return
    end

    # 休憩時間の重複チェック
    @attendance.breaks.where.not(id: @break.id).each do |break_time|
      if (break_time.start_time.strftime('%H:%M:%S')..break_time.end_time.strftime('%H:%M:%S')).cover?(start_time) || (break_time.start_time.strftime('%H:%M:%S')..break_time.end_time.strftime('%H:%M:%S')).cover?(end_time)
        flash[:error] = "休憩時間が重複しています"
        render 'breaks/edit'
        return
      end
    end

    if @break.update(break_params)
      flash[:success] = "休憩時間を更新しました"
      redirect_to user_attendance_day_path(user_id, work_day)
    else
      flash[:error] = "休憩時間を更新できませんでした"
      render 'breaks/edit'
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
    @attendance = @user.attendances.find_by(work_day: Time.current)
  
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

    def check_break_params
      params.require(:break).permit(:start_time, :end_time)
    end

    def valid_date_day?(date)
      begin
        Date.parse(date)
        return true
      rescue ArgumentError
        return false
      end
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
