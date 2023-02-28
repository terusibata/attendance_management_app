class AttendancesController < ApplicationController
  def show_by_day
    @user = User.find(params[:user_id])
    # work_dayがparams[:date]のレコードを取得
    if params[:date].nil?
      @attendance = @user.attendances.find_by(work_day: Date.today)
    else
      @attendance = @user.attendances.find_by(work_day: params[:date])
    end
  end

end
