class AttendancesController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user,   only: [:show_by_day, :show_by_month, :new, :edit, :create, :update, :destroy]
  before_action :admin_user,     only: [:show_admin_by_day, :show_admin_by_month]
  
  def index
    @attendances = Attendance.all
  end

  def show_by_day
    @user = User.find(params[:user_id])
    # work_dayがparams[:date]のレコードを取得
    if params[:date].nil? || !valid_date_day?(params[:date])
      current_date = Time.current
    else
      current_date = Time.parse(params[:date])
    end
    @attendance = @user.attendances.find_by(work_day: current_date)
    # 前日の日付を計算します。
    yesterday = current_date - 1.day
    # 翌日の日付を計算します。
    tomorrow = current_date + 1.day
    # もし、@attendanceがnilなら
    @attendance_data = calculate_working_time(@attendance)
    
    # 結果を変数に代入します。
    @current_date = current_date.strftime('%Y年%m月%d日')
    @new_create_date = current_date.strftime('%Y-%m-%d')
    @yesterday = yesterday.strftime('%Y-%m-%d')
    @tomorrow = tomorrow.strftime('%Y-%m-%d')
    @working_time_str = @attendance_data[:working_time_str]
    @break_time_str = @attendance_data[:break_time_str]
    @break_time_list = @attendance_data[:break_time_list]
  end

  def show_by_month
    @user = User.find(params[:user_id])
  
    # 与えられた月の初日と末日を計算します。
    if params[:month].nil? || !valid_date_month?(params[:month])
      current_month = Time.current.beginning_of_month
    else
      current_month = Time.new(params[:month].split('-')[0].to_i, params[:month].split('-')[1].to_i, 1)
    end

    # その月の最初の日を取得
    first_day = current_month.beginning_of_month
    # その月の最後の日を取得
    last_day = current_month.end_of_month
    # その月の日数を計算
    days_in_month = last_day.day
    
    # 与えられた月のすべての日付に対する出勤情報を取得します。
    @attendances = @user.attendances.where(work_day: first_day..last_day).order(work_day: :asc)
  
    # 与えられた月の実労働時間と休憩時間を計算します。
    working_seconds = 0
    break_seconds = 0
    @attendances.each do |attendance|
      break_time_list = attendance.breaks.order(start_time: :asc, id: :asc).all
      break_seconds = break_time_list.map { |break_time|
        break_time.end_time.present? && break_time.start_time.present? ? break_time.end_time - break_time.start_time : 0
      }.sum
      # 出勤時間と退勤時間が両方存在する場合のみ、実労働時間を計算します。
      if attendance.start_time.present? && attendance.end_time.present?
        working_seconds += attendance.end_time - attendance.start_time - break_seconds
      end
      puts "working_seconds: #{working_seconds}"
    end
    
    # 結果を変数に代入します。
    @current_month = current_month.strftime('%Y年%m月')
    @prev_month = (current_month - 1.month).strftime('%Y-%m')
    @next_month = (current_month + 1.month).strftime('%Y-%m')
    @working_time_total_str = convert_seconds_to_time_str(working_seconds)
    @break_time_total_str = convert_seconds_to_time_str(break_seconds)

    # すべての日付に対する出勤情報を作成します。
    @month_attendances = []
    wd = ["日", "月", "火", "水", "木", "金", "土"]
    days_in_month.times do |i|
      # 出勤日を取得
      work_day = first_day + i.days
      attendance = @user.attendances.find_by(work_day: work_day)
      if attendance.nil?
        attendance_data = {
          status: "未登録",
          work_day: work_day.strftime('%Y-%m-%d'),
          day_str: work_day.strftime("%d日(#{wd[work_day.wday]})"),
        }
      else
        @attendance_time = calculate_working_time(attendance)
        attendance_data = {
          status: "登録済",
          id: attendance.id,
          work_day: work_day.strftime('%Y-%m-%d'),
          day_str: work_day.strftime("%d日(#{wd[work_day.wday]})"),
          start_time: attendance.start_time,
          end_time: attendance.end_time,
          working_time: @attendance_time[:working_time],
          break_time: @attendance_time[:break_time],
          working_time_str: @attendance_time[:working_time_str],
          break_time_str: @attendance_time[:break_time_str]
        }
      end
      # 出勤情報を配列に追加します。
      @month_attendances << attendance_data
    end
  end

  def show_admin_by_day
    if params[:date].nil? || !valid_date_day?(params[:date])
      current_date = Time.current
    else
      current_date = Time.parse(params[:date])
    end
  
    # 全従業員のレコードを取得
    @users = User.all

    # 与えられた日付の出勤情報を取得します。
    @day_attendances = []
    @users.each do |user|
      attendance = user.attendances.find_by(work_day: current_date)
      if attendance.nil?
        attendance_data = {
          status: "未登録",
          user_id: user.id,
          user_name: user.name
        }
      else
        @attendance_time = calculate_working_time(attendance)
        attendance_data = {
          status: "登録済",
          id: attendance.id,
          user_id: user.id,
          user_name: user.name,
          start_time: attendance.start_time,
          end_time: attendance.end_time,
          working_time: @attendance_time[:working_time],
          break_time: @attendance_time[:break_time],
          working_time_str: @attendance_time[:working_time_str],
          break_time_str: @attendance_time[:break_time_str]
        }
      end
      # 出勤情報を配列に追加します。
      @day_attendances << attendance_data
    end

    # 結果を変数に代入します。
    @current_date = current_date.strftime('%Y年%m月%d日')
    @current_date_day = current_date.strftime('%Y-%m-%d')
    @yesterday = (current_date - 1.day).strftime('%Y-%m-%d')
    @tomorrow = (current_date + 1.day).strftime('%Y-%m-%d')
  end

  def show_admin_by_month
    if params[:month].nil? || !valid_date_month?(params[:month])
      current_month = Time.current.beginning_of_month
    else
      current_month = Time.new(params[:month].split('-')[0].to_i, params[:month].split('-')[1].to_i, 1)
    end

    # 全従業員のレコードを取得
    @users = User.all

    # その月の最初の日を取得
    first_day = current_month.beginning_of_month
    # その月の最後の日を取得
    last_day = current_month.end_of_month
    # その月の日数を計算
    days_in_month = last_day.day

    # ["2月1日","2日"...""]
    @days = []
    wd = ["日", "月", "火", "水", "木", "金", "土"]
    days_in_month.times do |i|
      @days << {
        day_str: (first_day + i.days).strftime("%d日(#{wd[(first_day + i.days).wday]})"),
        day: (first_day + i.days).strftime('%Y-%m-%d')
      }
    end

    # その月の出勤情報を取得します。
    @month_attendances = []
    @users.each do |user|
      # 与えられた月のすべての日付に対する出勤情報を取得します。
      attendances = user.attendances.where(work_day: first_day..last_day).order(work_day: :asc)

      # 与えられた月の実労働時間と休憩時間を計算します。
      working_seconds = 0
      break_seconds = 0
      attendances.each do |attendance|
        break_time_list = attendance.breaks.order(start_time: :asc, id: :asc).all
        break_seconds = break_time_list.map { |break_time|
          break_time.end_time.present? && break_time.start_time.present? ? break_time.end_time - break_time.start_time : 0
        }.sum
        # 出勤時間と退勤時間が両方存在する場合のみ、実労働時間を計算します。
        if attendance.start_time.present? && attendance.end_time.present?
          working_seconds += attendance.end_time - attendance.start_time - break_seconds
        end
      end

      @day_attendances = []
      error_count = 0
      # 与えられた月のすべての日付に対する出勤情報を取得します。
      days_in_month.times do |i|
        # 出勤日を取得
        work_day = first_day + i.days
        attendance = user.attendances.find_by(work_day: work_day)
        if attendance.nil?
          attendance_data = {
            status: "未登録",
            work_day: work_day.strftime('%Y-%m-%d'),
          }
        else
          @attendance_time = calculate_working_time(attendance)
          if attendance.start_time.nil?
            error_count += 1
          end
          if attendance.end_time.nil?
            error_count += 1
          end
          attendance_data = {
            status: "登録済",
            id: attendance.id,
            work_day: work_day.strftime('%Y-%m-%d'),
            start_time: attendance.start_time,
            end_time: attendance.end_time,
            working_time: @attendance_time[:working_time],
            break_time: @attendance_time[:break_time],
            working_time_str: @attendance_time[:working_time_str],
            break_time_str: @attendance_time[:break_time_str]
          }
        end
        # 出勤情報を配列に追加します。
        @day_attendances << attendance_data
      end
      
      # 結果を変数に代入します。
      @month_attendances << {
        user_id: user.id,
        user_name: user.name,
        error_count: error_count,
        attendances: @day_attendances,
        working_seconds: working_seconds,
        break_seconds: break_seconds,
        working_time_total_str: convert_seconds_to_time_str(working_seconds),
        break_time_total_str: convert_seconds_to_time_str(break_seconds)
      }
    end

    # 結果を変数に代入します。
    @current_month = current_month.strftime('%Y年%m月')
    @current_month_day = current_month.strftime('%Y-%m')
    @last_month = (current_month - 1.month).strftime('%Y-%m')
    @next_month = (current_month + 1.month).strftime('%Y-%m')
    
  end
  
  def new
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.build
    if params[:date].nil? || !valid_date_day?(params[:date])
      current_date = Time.current
    else
      current_date = Time.parse(params[:date])
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
      render 'attendances/new'
      return
    else
      current_date = Time.parse(params[:date])
    end
    @new_create_date = current_date.strftime('%Y-%m-%d')
    @current_date = current_date.strftime('%Y年%m月%d日')
    @attendance = @user.attendances.build(attendance_params)
    if @attendance.start_time.nil?
      flash[:error] = "出勤時間を入力してください"
      render 'attendances/new'
      return
    elsif @attendance.end_time.nil?
      flash[:error] = "退勤時間を入力してください"
      render 'attendances/new'
      return
    end

    if @attendance.start_time > @attendance.end_time
      flash[:error] = "勤務時間が無効です"
      render 'attendances/new'
      return
    end

    if @attendance.save
      flash[:success] = "勤怠を登録しました"
      redirect_to user_attendance_day_path(@user, @attendance.work_day)
    else
      flash[:error] = "登録に失敗しました"
      render 'attendances/new'
    end
  end

  def update
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find_by(work_day: params[:date])
    if params[:date].nil? || !valid_date_day?(params[:date])
      flash[:error] = "日付が無効です"
      render 'attendances/edit'
      return
    else
      current_date = Time.parse(params[:date])
    end
    @new_create_date = current_date.strftime('%Y-%m-%d')
    @current_date = current_date.strftime('%Y年%m月%d日')

    if @attendance.start_time.nil?
      flash[:error] = "出勤時間を入力してください"
      render 'attendances/edit'
      return
    elsif @attendance.end_time.nil?
      flash[:error] = "退勤時間を入力してください"
      render 'attendances/edit'
      return
    end

    if @attendance.start_time > @attendance.end_time
      flash[:error] = "勤務時間が無効です"
      render 'attendances/edit'
      return
    end

    breaks = @attendance.breaks

    if breaks.present? && breaks[0].start_time.strftime('%H:%M:%S') < Time.parse(check_attendance_params[:start_time]).strftime('%H:%M:%S')
      flash[:error] = "出勤時間が休憩開始時間よりも遅いです"
      render 'attendances/edit'
      return
    end

    if breaks.present? && breaks[breaks.length - 1].end_time.strftime('%H:%M:%S') > Time.parse(check_attendance_params[:end_time]).strftime('%H:%M:%S')
      flash[:error] = "退勤時間が休憩終了時間よりも早いです"
      render 'attendances/edit'
      return
    end

    if @attendance.update(attendance_params)
      flash[:success] = "勤怠を更新しました"
      redirect_to user_attendance_day_path(@user, @attendance.work_day)
    else
      flash[:error] = "更新に失敗しました"
      render 'attendances/edit'
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
    @attendance = @user.attendances.find_by(work_day: Time.current)
    if @attendance
      flash[:error] = "すでに出勤は登録されています"
      redirect_to root_path
    else
      @attendance = @user.attendances.create(work_day: Time.current, start_time: Time.current.strftime('%H:%M'))
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
    @attendance = @user.attendances.find_by(work_day: Time.current)
  
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

    def check_attendance_params
      params.require(:attendance).permit(:user_id, :start_time, :end_time)
    end

    def valid_date_day?(date)
      begin
        Date.parse(date)
        return true
      rescue ArgumentError
        return false
      end
    end

    def valid_date_month?(date)
      /\A\d{4}-\d{2}\z/ === date
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

    # その日の勤怠時間を計算します。
    def calculate_working_time(attendance)
      # もし、@attendanceがnilなら
      if attendance.nil? || attendance.start_time.nil? || attendance.end_time.nil?
        # 0を代入します。
        working_time_str = '--'
        break_time_str = '--'
      else
        # 休憩時間を取得
        break_time_list = attendance.breaks.order(start_time: :asc, id: :asc).all
        # もし、break_time_listがnilなら
        if break_time_list.count.zero?
          # 0を代入します。
          break_time_str = '--'
          break_seconds = 0
        else
          # 休憩時間を計算します。
          break_seconds = break_time_list.map { |break_time|
            break_time.end_time.present? && break_time.start_time.present? ? break_time.end_time - break_time.start_time : 0
          }.sum
        end
        # 労働時間を計算します。
        working_seconds = attendance.end_time - attendance.start_time - break_seconds
      end

      # 返す値を設定します。
      return {
        break_time_list: break_time_list,
        working_seconds: working_seconds,
        break_seconds: break_seconds,
        working_time_str: convert_seconds_to_time_str(working_seconds),
        break_time_str: convert_seconds_to_time_str(break_seconds)
      }
    end

    # 秒数を"?時間?分"の形式の文字列に変換します。
    def convert_seconds_to_time_str(seconds)
      if seconds.nil?
        return '--'
      else
        hours = seconds / 3600
        minutes = (seconds % 3600) / 60
        if hours.floor.zero?
          return "#{minutes.to_i}分"
        else
          return "#{hours.to_i}時間#{minutes.to_i}分"
        end
      end
    end
end
