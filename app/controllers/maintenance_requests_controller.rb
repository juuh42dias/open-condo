class MaintenanceRequestsController < ApplicationController
  before_action :set_request, only: %i[show edit update destroy start complete cancel]
  before_action :authorize_request_access!, only: %i[show edit update]
  before_action :require_staff!, only: %i[start complete]
  before_action :require_admin!, only: %i[destroy]

  def index
    @requests = (staff_user? ? MaintenanceRequest.all : MaintenanceRequest.for_user(current_user))
      .by_priority
      .includes(:user, :unit)
  end

  def show; end

  def new
    @maintenance_request = MaintenanceRequest.new(priority: "medium", category: "other")
    @units = available_units
  end

  def create
    @maintenance_request = current_user.maintenance_requests.new(request_params)
    @maintenance_request.status ||= "pending"

    unless available_units.exists?(id: @maintenance_request.unit_id)
      @units = available_units
      @maintenance_request.errors.add(:unit, "is not available to you")
      return render :new, status: :unprocessable_entity
    end

    if @maintenance_request.save
      redirect_to @maintenance_request, notice: "Maintenance request submitted."
    else
      @units = available_units
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @units = available_units
  end

  def update
    if @maintenance_request.update(request_params)
      redirect_to @maintenance_request, notice: "Maintenance request updated."
    else
      @units = available_units
      render :edit, status: :unprocessable_entity
    end
  end

  def start
    @maintenance_request.mark_in_progress!
    redirect_to @maintenance_request, notice: "Request marked as in progress.", status: :see_other
  end

  def complete
    @maintenance_request.mark_completed!
    redirect_to @maintenance_request, notice: "Request marked as completed.", status: :see_other
  end

  def cancel
    unless staff_user? || @maintenance_request.user == current_user
      return redirect_to root_path, alert: "You are not authorized to perform this action."
    end

    @maintenance_request.cancel!
    redirect_to @maintenance_request, notice: "Request cancelled.", status: :see_other
  end

  def destroy
    @maintenance_request.destroy
    redirect_to maintenance_requests_path, notice: "Request deleted.", status: :see_other
  end

  private

  def available_units
    units = current_user.units
    units.respond_to?(:ordered) ? units.ordered.includes(:building) : units
  end

  def set_request
    @maintenance_request = MaintenanceRequest.find(params[:id])
  end

  def authorize_request_access!
    return if staff_user? || @maintenance_request.user == current_user

    redirect_to root_path, alert: "You are not authorized to view this request."
  end

  def request_params
    permitted = %i[title description priority category unit_id status]
    permitted -= %i[status] unless staff_user?
    params.require(:maintenance_request).permit(*permitted)
  end
end
