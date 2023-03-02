class AttendancesController < ApplicationController
  def show_by_day
    @user = User.find(params[:user_id])
    # work_dayがparams[:date]のレコードを取得
    if params[:date].nil? || !valid_date_day?(params[:date])
      current_date = Date.today
    else
      current_date = DateTime.parse(params[:date])
    end
    @attendance = @user.attendances.find_by(work_day: current_date)
    # 前日の日付を計算します。
    yesterday = current_date - 1.day
    # 翌日の日付を計算します。
    tomorrow = current_date + 1.day
    # もし、@attendanceがnilなら
    if @attendance.nil? || @attendance.start_time.nil? || @attendance.end_time.nil?
      # 0を代入します。
      working_time_str = '--'
      break_time_str = '--'
    else
      # 労働時間を計算します。
      working_seconds = @attendance.end_time - @attendance.start_time
      working_hours = working_seconds / 3600
      working_minutes = (working_seconds % 3600) / 60
      # 労働時間を「時間:分」の形式で表記します。
      working_time_str = format('%d時間%d分', working_hours.to_i, working_minutes.to_i)

      # 休憩時間を取得
      @break_time_list = @attendance.breaks.order(start_time: :asc, id: :asc).all
      # もし、break_time_listがnilなら
      if @break_time_list.count.zero?
        # 0を代入します。
        break_time_str = '--'
      else
        # 休憩時間を計算します。
        break_seconds = @break_time_list.map { |break_time|
          break_time.end_time.present? && break_time.start_time.present? ? break_time.end_time - break_time.start_time : 0
        }.sum
        break_hours = break_seconds / 3600
        break_minutes = (break_seconds % 3600) / 60
        # 休憩時間を「時間:分」の形式で表記します。
        break_time_str = format('%d時間%d分', break_hours.to_i, break_minutes.to_i)
      end
    end
    
    # 結果を変数に代入します。
    @current_date = current_date.strftime('%Y年%m月%d日')
    @new_create_date = current_date.strftime('%Y-%m-%d')
    @yesterday = yesterday.strftime('%Y-%m-%d')
    @tomorrow = tomorrow.strftime('%Y-%m-%d')
    @working_time_str = working_time_str
    @break_time_str = break_time_str
  end
  
  def new
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.build
    if params[:date].nil? || !valid_date_day?(params[:date])
      current_date = Date.today
    else
      current_date = DateTime.parse(params[:date])
    end
    @current_date = current_date.strftime('%Y年%m月%d日')
    @new_create_date = current_date.strftime('%Y-%m-%d')
  end

  def edit
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find_by(work_day: params[:date])
    @current_date = @attendance.work_day.strftime('%Y年%m月%d日')
    @new_create_date = @attendance.work_day.strftime('%Y-%m-%d')
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
    @attendance = @user.attendances.build(attendance_params)
    if @attendance.save
      flash[:success] = "勤怠を登録しました"
      redirect_to user_attendance_day_path(@user, @attendance.work_day)
    else
      render 'new'
    end
  end

  def update
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find_by(work_day: params[:date])
    if params[:date].nil? || !valid_date_day?(params[:date])
      flash[:error] = "日付が無効です"
      render 'edit'
      return
    else
      current_date = DateTime.parse(params[:date])
    end
    @new_create_date = current_date.strftime('%Y-%m-%d')
    if @attendance.update(attendance_params)
      flash[:success] = "勤怠を更新しました"
      redirect_to user_attendance_day_path(@user, @attendance.work_day)
    else
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find_by(work_day: params[:date])
    @attendance.destroy
    flash[:success] = "勤怠を削除しました"
    redirect_to user_attendance_day_path(@user, params[:date])
  end

  def start
    @user = current_user
    @attendance = @user.attendances.find_by(work_day: Date.today)
    if @attendance
      flash[:error] = "すでに出勤は登録されています"
      redirect_to root_path
    else
      @attendance = @user.attendances.create(work_day: Date.today, start_time: Time.current.strftime('%H:%M'))
      if @attendance.save
        flash[:success] = "出勤しました"
        redirect_to root_path
      else
        flash[:error] = "出勤処理に失敗しました"
        redirect_to root_path
      end
    end
  end

  def end
    @user = current_user
    @attendance = @user.attendances.find_by(work_day: Date.today)
  
    if !@attendance
      flash[:error] = "勤怠を開始していません"
      redirect_to root_path
    elsif @attendance.end_time
      flash[:error] = "すでに勤怠を終了しています"
      redirect_to root_path
    elsif !@attendance.start_time
      flash[:error] = "出勤時間が登録されていません"
      redirect_to root_path
    else
      @attendance.update(end_time: Time.current.strftime('%H:%M'))
      flash[:success] = "退勤しました"
      redirect_to root_path
    end
  end
  
  private
    def attendance_params
      params.require(:attendance).permit(:user_id, :start_time, :end_time).merge(work_day: @new_create_date)
    end

    def valid_date_day?(date)
      Date.valid_date?(*date.split('-').map(&:to_i))
    end
end
