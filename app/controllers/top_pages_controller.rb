class TopPagesController < ApplicationController
  def home
    if !logged_in?
      # login_pathへリダイレクト
      redirect_to login_path
    end
  end
end