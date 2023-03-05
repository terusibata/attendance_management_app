class TopPagesController < ApplicationController
  before_action :logged_in_user, only: [:home]

  def home
    @user = current_user
    @attendance = @user.attendances.find_by(work_day: Time.current)
  
    if @attendance.nil?
      @status = "出勤前"
    elsif @attendance.end_time.nil?
      @status = "勤務中"
      @break = @attendance.breaks.find_by(end_time: nil)
      if @break.present?
        @status = "休憩中"
      end
    else
      @status = "退勤済"
    end

    if current_user.admin?
      # 全てのユーザーごとの勤怠情報を取得
      @users = User.all
      @now_user_attendances = []
      @now_attendance_count = { "出勤前": 0, "勤務中": 0, "休憩中": 0, "退勤済": 0 }
      @this_month_attendance_list = []

      # その月の最初の日を取得
      today = Time.current
      first_day = today.beginning_of_month
      # その月の最後の日を取得
      last_day = today.end_of_month

      @users.each do |user|
        user_attendance = user.attendances.find_by(work_day: Time.current)

        if user_attendance.nil?
          user_status = "出勤前"
          comment = "本日はまだ出勤していません"
        elsif user_attendance.end_time.nil?
          user_status = "勤務中"
          comment = "現在、勤務中です"
          user_break = user_attendance.breaks.find_by(end_time: nil)
          if user_break.present?
            user_status = "休憩中"
            comment = "現在、休憩中です"
          end
        else
          user_status = "退勤済"
          comment = "本日は退勤済です"
        end

        @now_attendance_count[user_status.to_sym] += 1

        @now_user_attendances << {
          user_name: user.name,
          user_id: user.id,
          comment: comment,
          now_working_time: now_working_time(user_attendance),
          attendance: user_attendance, 
          status: user_status
        }

        attendances = user.attendances.where(work_day: first_day..last_day).order(work_day: :asc)

        working_seconds = 0
        break_seconds = 0
        attendances.each do |attendance|
          break_time_list = attendance.breaks.order(start_time: :asc, id: :asc).all
          break_seconds += break_time_list.map { |break_time|
            break_time.end_time.present? && break_time.start_time.present? ? break_time.end_time - break_time.start_time : 0
          }.sum
          # 出勤時間と退勤時間が両方存在する場合のみ、実労働時間を計算します。
          if attendance.start_time.present? && attendance.end_time.present?
            working_seconds += attendance.end_time - attendance.start_time - break_seconds
          end
        end

        @this_month_attendance_list << {
          user_name: user.name,
          user_id: user.id,
          working_seconds: working_seconds,
          break_seconds: break_seconds,
          working_time_str: convert_seconds_to_time_str(working_seconds),
          break_time_str: convert_seconds_to_time_str(break_seconds)
        }
      end

      # this_month_attendance_listのworking_secondsが降順になるようにソートします。
      @this_month_attendance_list.sort! { |a, b| b[:working_seconds] <=> a[:working_seconds] }

    end
  end

  private
    # ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:error] = "ログインしてください"
        redirect_to login_url
      end
    end

    # 今の勤怠時間を計算します。
    def now_working_time(attendance)
      # もし、@attendanceがnilなら
      if attendance.nil? || attendance.start_time.nil?
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
            break_time.end_time.present? && break_time.start_time.present? ? 
            break_time.end_time - break_time.start_time : break_time.start_time.present? && break_time.end_time.nil? ?
            Time.parse(Time.current.strftime('%X')) - Time.parse(break_time.start_time.strftime('%X')) : 0
          }.sum
        end
        # 労働時間を計算します。
        if attendance.end_time.nil?
          working_seconds = Time.parse(Time.current.strftime('%X')) - Time.parse(attendance.start_time.strftime('%X')) - break_seconds
        else
          working_seconds = attendance.end_time - attendance.start_time - break_seconds
        end
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
        puts hours
        if hours.floor.zero?
          return "#{minutes.to_i}分"
        else
          return "#{hours.to_i}時間#{minutes.to_i}分"
        end
      end
    end
end