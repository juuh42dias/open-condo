# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  helper_method :staff_user?

  private

  def staff_user?
    user_signed_in? && current_user.staff?
  end

  def require_staff!
    return if staff_user?

    redirect_to root_path, alert: "You are not authorized to perform this action."
  end

  def require_admin!
    return if user_signed_in? && current_user.admin?

    redirect_to root_path, alert: "Administrator access is required."
  end

  def require_resident_or_owner!
    return if user_signed_in? && (current_user.resident? || current_user.owner?)

    redirect_to root_path, alert: "Only residents and owners can do that."
  end
end
