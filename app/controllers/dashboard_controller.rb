class DashboardController < ApplicationController
  def index
    @buildings = Building.ordered
    @units = Unit.all
    @notices = Notice.active.by_priority.limit(5)
    @open_requests = MaintenanceRequest.open_requests.by_priority
    @upcoming_reservations = Reservation.upcoming.limit(5)

    if staff_user?
      @pending_visitors = Visitor.pending_approval.ordered.limit(5)
      @overdue_payments = Payment.overdue.ordered.limit(5)
      @payments_due_total = Payment.where(status: %w[pending overdue]).sum(:amount)
      @maintenance_count = @open_requests.count
      @awaiting_packages = Package.awaiting_pickup.ordered.limit(5)
      @awaiting_packages_count = Package.awaiting_pickup.count
      @open_violations = Violation.open_cases.ordered.limit(5)
      @open_violations_count = Violation.open_cases.count
      @active_polls = Poll.open_polls.ordered.limit(5)
      @financial_summary = Payment.financial_summary
    else
      @my_requests = MaintenanceRequest.for_user(current_user).ordered.limit(5)
      @my_reservations = Reservation.for_user(current_user).upcoming.limit(5)
      @my_payments = Payment.where(unit_id: current_user.units.select(:id)).ordered.limit(5)
      @my_balance = Payment.where(unit_id: current_user.units.select(:id), status: %w[pending overdue]).sum(:amount)
      @my_packages = Package.for_units(current_user.units.select(:id)).awaiting_pickup.ordered.limit(5)
      @my_violations = Violation.for_units(current_user.units.select(:id)).open_cases.ordered.limit(5)
      building_ids = current_user.units.select(:building_id)
      @open_polls = Poll.open_polls.where(building_id: building_ids).ordered.limit(5)
    end
  end
end
