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
    @current_date = current_date.strftime('%Y-%m-%d')
    @yesterday = yesterday.strftime('%Y-%m-%d')
    @tomorrow = tomorrow.strftime('%Y-%m-%d')
    @working_time_str = working_time_str
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
