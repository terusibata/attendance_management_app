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

end