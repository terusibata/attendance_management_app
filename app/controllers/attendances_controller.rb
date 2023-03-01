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
    else
      # 労働時間を計算します。
      working_hours = (@attendance.end_time - @attendance.start_time) / 3600
      # 労働時間を「時間:分」の形式で表記します。
      working_time_str = format('%d時間%d分', working_hours.to_i, (working_hours % 1 * 60).to_i)
    end
    
    # 結果を変数に代入します。
    @current_date = current_date.strftime('%Y年%m月%d日')
    @new_create_date = current_date.strftime('%Y-%m-%d')
    @yesterday = yesterday.strftime('%Y-%m-%d')
    @tomorrow = tomorrow.strftime('%Y-%m-%d')
    @working_time_str = working_time_str
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
    @attendance = @user.attendances.build(attendance_params)
    if @attendance.save
      flash[:success] = "勤怠を登録しました"
      redirect_to user_attendance_day_path(@user, @attendance.work_day)
    else
      render 'new'
    end
  end

  private
    def attendance_params
      params.require(:attendance).permit(:user_id, :start_time, :end_time).merge(work_day: @new_create_date)
    end

    def valid_date_day?(date_string)
      # YYYY-MM-DD のフォーマットでなければ無効
      return false unless date_string =~ /^\d{4}-\d{2}-\d{2}$/
    
      begin
        # パースできなければ無効
        Date.parse(date_string)
        true
      rescue ArgumentError
        false
      end
    end
end
