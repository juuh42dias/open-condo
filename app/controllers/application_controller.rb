# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  private
  
  def authenticate_user!
    redirect_to new_user_session_path unless user_signed_in?
  end
end
