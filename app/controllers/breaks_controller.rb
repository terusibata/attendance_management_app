class BreaksController < ApplicationController
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
      flash[:danger] = "日付が無効です"
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

  private
    def break_params
      params.require(:break).permit(:start_time, :end_time)
    end

    def valid_date_day?(date)
      Date.valid_date?(*date.split('-').map(&:to_i))
    end
end
