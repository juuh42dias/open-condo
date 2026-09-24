class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[show mark_paid mark_pending]
  before_action :require_staff!, only: %i[new create mark_paid mark_pending generate_monthly apply_late_fees mark_overdue]
  before_action :authorize_payment_access!, only: %i[show]

  def index
    @payments = (staff_user? ? Payment.all : Payment.where(unit_id: current_user.units.select(:id)))
      .ordered
      .includes(:user, unit: :building)
    @total_pending = @payments.select(&:pending?).sum(&:amount)
    @summary = Payment.financial_summary(staff_user? ? Payment.all : Payment.where(unit_id: current_user.units.select(:id)))
  end

  def show; end

  def new
    @payment = Payment.new(payment_type: "condo_fee", status: "pending", due_date: Date.current.end_of_month)
    @units = Unit.ordered.includes(:building)
  end

  def create
    @payment = Payment.new(payment_params)
    unit = Unit.find_by(id: @payment.unit_id)
    @payment.user = payer_for(unit)

    if @payment.user.nil?
      @payment.valid?
      @payment.errors.add(:base, "Selected unit has no resident or owner to bill.")
      @units = Unit.ordered.includes(:building)
      return render :new, status: :unprocessable_entity
    end

    if @payment.save
      redirect_to @payment, notice: "Charge created."
    else
      @units = Unit.ordered.includes(:building)
      render :new, status: :unprocessable_entity
    end
  end

  def mark_paid
    @payment.mark_as_paid!
    redirect_to @payment, notice: "Payment marked as paid.", status: :see_other
  end

  def mark_pending
    @payment.mark_as_pending!
    redirect_to @payment, notice: "Payment marked as pending.", status: :see_other
  end

  def generate_monthly
    amount = params[:amount].to_d
    return redirect_to payments_path, alert: "Enter a valid amount." if amount <= 0

    created = Payment.generate_monthly_fees!(amount: amount)
    redirect_to payments_path, notice: "#{created} monthly charge(s) generated."
  end

  def mark_overdue
    count = Payment.mark_overdue!
    redirect_to payments_path, notice: "#{count} charge(s) marked overdue.", status: :see_other
  end

  def apply_late_fees
    created = Payment.apply_late_fees!(percentage: 2.0)
    redirect_to payments_path, notice: "#{created} late fee(s) applied.", status: :see_other
  end

  private

  def payer_for(unit)
    return nil unless unit

    unit.current_resident&.user || unit.owners.first&.user || unit.payments.first&.user
  end

  def set_payment
    @payment = Payment.find(params[:id])
  end

  def authorize_payment_access!
    return if staff_user? || current_user.units.exists?(id: @payment.unit_id)

    redirect_to root_path, alert: "You are not authorized to view this payment."
  end

  def payment_params
    params.require(:payment).permit(:amount, :payment_type, :due_date, :description, :status, :unit_id)
  end
end
