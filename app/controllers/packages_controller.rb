class PackagesController < ApplicationController
  before_action :set_package, only: %i[show notify_pickup mark_picked_up mark_returned destroy]
  before_action :require_staff!, only: %i[new create notify_pickup mark_picked_up mark_returned destroy]
  before_action :authorize_package_access!, only: %i[show]

  def index
    base = staff_user? ? Package.all : Package.for_units(current_user.units.select(:id))
    @packages = base.ordered.includes(unit: :building)
    @awaiting_count = base.awaiting_pickup.count
  end

  def show; end

  def new
    @package = Package.new(status: "received")
    @units = Unit.ordered.includes(:building)
  end

  def create
    @package = Package.new(package_params)

    if @package.save
      redirect_to @package, notice: "Package logged."
    else
      @units = Unit.ordered.includes(:building)
      render :new, status: :unprocessable_entity
    end
  end

  def notify_pickup
    @package.notify!
    redirect_to @package, notice: "Resident notified.", status: :see_other
  end

  def mark_picked_up
    @package.mark_picked_up!
    redirect_to @package, notice: "Package marked as picked up.", status: :see_other
  end

  def mark_returned
    @package.mark_returned!
    redirect_to @package, notice: "Package marked as returned.", status: :see_other
  end

  def destroy
    @package.destroy
    redirect_to packages_path, notice: "Package removed.", status: :see_other
  end

  private

  def set_package
    @package = Package.find(params[:id])
  end

  def authorize_package_access!
    return if staff_user? || current_user.units.exists?(id: @package.unit_id)

    redirect_to root_path, alert: "You are not authorized to view this package."
  end

  def package_params
    params.require(:package).permit(:unit_id, :recipient_name, :sender, :carrier, :tracking_code, :notes)
  end
end
