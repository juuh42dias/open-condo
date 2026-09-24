class ViolationsController < ApplicationController
  before_action :set_violation, only: %i[show edit update destroy acknowledge resolve dismiss convert_to_fine]
  before_action :authorize_violation_access!, only: %i[show edit update]
  before_action :require_staff!, only: %i[acknowledge resolve dismiss convert_to_fine]
  before_action :require_admin!, only: %i[destroy]

  def index
    base = staff_user? ? Violation.all : Violation.for_units(current_user.units.select(:id))
    @violations = base.ordered.includes(:unit, :reported_by)
    @open_count = base.open_cases.count
  end

  def show; end

  def new
    @violation = Violation.new(severity: "medium", violation_type: "other")
    @units = available_units
  end

  def create
    @violation = Violation.new(violation_params)
    @violation.reported_by = current_user
    @violation.status ||= "open"

    unless available_units.exists?(id: @violation.unit_id)
      @units = available_units
      @violation.errors.add(:unit, "is not available to you")
      return render :new, status: :unprocessable_entity
    end

    if @violation.save
      redirect_to @violation, notice: "Violation reported."
    else
      @units = available_units
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @units = available_units
  end

  def update
    if @violation.update(violation_params)
      redirect_to @violation, notice: "Violation updated."
    else
      @units = available_units
      render :edit, status: :unprocessable_entity
    end
  end

  def acknowledge
    @violation.acknowledge!
    redirect_to @violation, notice: "Violation acknowledged.", status: :see_other
  end

  def resolve
    @violation.resolve!
    redirect_to @violation, notice: "Violation resolved.", status: :see_other
  end

  def dismiss
    @violation.dismiss!
    redirect_to @violation, notice: "Violation dismissed.", status: :see_other
  end

  def convert_to_fine
    @violation.update!(fine_amount: params[:fine_amount]) if params[:fine_amount].present?
    payment = @violation.convert_to_fine!
    redirect_to payment, notice: "Fine issued for this violation."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to @violation, alert: "Could not issue fine: #{e.record.errors.full_messages.to_sentence}"
  end

  def destroy
    @violation.destroy
    redirect_to violations_path, notice: "Violation deleted.", status: :see_other
  end

  private

  def available_units
    units = staff_user? ? Unit.all : current_user.units
    units.respond_to?(:ordered) ? units.ordered.includes(:building) : units
  end

  def set_violation
    @violation = Violation.find(params[:id])
  end

  def authorize_violation_access!
    return if staff_user? || @violation.reported_by == current_user || current_user.units.exists?(id: @violation.unit_id)

    redirect_to root_path, alert: "You are not authorized to view this violation."
  end

  def violation_params
    permitted = %i[title description violation_type severity unit_id fine_amount]
    permitted += %i[status] if staff_user?
    params.require(:violation).permit(*permitted)
  end
end
