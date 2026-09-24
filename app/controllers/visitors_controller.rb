class VisitorsController < ApplicationController
  before_action :set_visitor, only: %i[show approve reject check_in check_out destroy]
  before_action :require_staff!, only: %i[approve reject check_in check_out]
  before_action :authorize_visitor_access!, only: %i[show destroy]

  def index
    @visitors = (staff_user? ? Visitor.all : current_user.visitors)
      .ordered
      .includes(resident: { unit: :building })
    @pending_count = @visitors.select(&:pending?).count
  end

  def show; end

  def new
    @visitor = Visitor.new(visit_date: Date.current, approved: false)
    @units = staff_user? ? Unit.ordered.includes(:building) : current_user.units
    @selected_unit_id = current_user.resident&.unit_id
  end

  def create
    resident = resident_for_new_visitor

    unless resident
      @visitor = Visitor.new(visitor_params)
      @visitor.valid?
      @visitor.errors.add(:base, "No resident is assigned to the selected unit. Please assign a resident first.")
      @units = staff_user? ? Unit.ordered.includes(:building) : current_user.units
      return render :new, status: :unprocessable_entity
    end

    @visitor = resident.visitors.new(visitor_params)
    @visitor.approved = false
    @visitor.approved_at = nil

    if @visitor.save
      redirect_to @visitor, notice: "Visitor registered. Awaiting approval."
    else
      @units = staff_user? ? Unit.ordered.includes(:building) : current_user.units
      render :new, status: :unprocessable_entity
    end
  end

  def approve
    @visitor.approve!
    redirect_to @visitor, notice: "Visitor approved.", status: :see_other
  end

  def reject
    @visitor.reject!
    redirect_to @visitor, notice: "Visitor rejected.", status: :see_other
  end

  def check_in
    @visitor.check_in!
    redirect_to @visitor, notice: "Visitor checked in.", status: :see_other
  end

  def check_out
    @visitor.check_out!
    redirect_to @visitor, notice: "Visitor checked out.", status: :see_other
  end

  def destroy
    @visitor.destroy
    redirect_to visitors_path, notice: "Visitor removed.", status: :see_other
  end

  private

  def resident_for_new_visitor
    return current_user.resident if current_user.resident?

    unit = Unit.find_by(id: params.dig(:visitor, :unit_id))
    unit&.current_resident
  end

  def set_visitor
    @visitor = Visitor.find(params[:id])
  end

  def authorize_visitor_access!
    return if staff_user? || @visitor.resident.user == current_user

    redirect_to root_path, alert: "You are not authorized to view this visitor."
  end

  def visitor_params
    params.require(:visitor).permit(:name, :id_number, :phone, :visit_date, :visit_time, :purpose)
  end
end
