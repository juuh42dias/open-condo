require "test_helper"

class PaymentAutomationTest < ActiveSupport::TestCase
  def setup
    @building = Building.create!(name: "T1", address: "A", total_units: 10)
    @unit = Unit.create!(unit_number: "101", building: @building, unit_type: "apartment",
                         bedrooms: 2, bathrooms: 1, area: 80, status: "occupied")
    @user = User.create!(name: "Res", email: "res-pay@example.com", password: "password123", role: "resident")
    Resident.create!(user: @user, unit: @unit, move_in_date: Date.current)
  end

  test "mark_overdue sweeps past-due pending" do
    payment = Payment.create!(user: @user, unit: @unit, amount: 100, payment_type: "condo_fee",
                              due_date: 2.days.ago.to_date, status: "pending", description: "Past due charge")
    Payment.mark_overdue!
    assert_equal "overdue", payment.reload.status
  end

  test "generate_monthly_fees is idempotent" do
    first_run = Payment.generate_monthly_fees!(amount: 500)
    assert first_run >= 1, "expected at least one charge generated"
    assert Payment.exists?(unit_id: @unit.id, payment_type: "condo_fee",
                           description: "Monthly condo fee - #{Date.current.strftime('%B %Y')}")
    second_run = Payment.generate_monthly_fees!(amount: 500)
    assert_equal 0, second_run
  end

  test "apply_late_fees creates one fee per overdue" do
    payment = Payment.create!(user: @user, unit: @unit, amount: 200, payment_type: "condo_fee",
                              due_date: 5.days.ago.to_date, status: "overdue", description: "Overdue charge")
    assert_equal 1, Payment.where(unit_id: @unit.id).apply_late_fees!(percentage: 10.0)
    assert_equal 0, Payment.where(unit_id: @unit.id).apply_late_fees!(percentage: 10.0)
    fee = Payment.find_by(description: "Late fee for charge ##{payment.id}")
    assert_not_nil fee
    assert_equal 20.0, fee.amount.to_f
  end

  test "financial_summary math" do
    scope = Payment.where(unit_id: @unit.id)
    scope.create!(user: @user, amount: 100, payment_type: "condo_fee",
                  due_date: Date.current, status: "paid", description: "Paid one")
    scope.create!(user: @user, amount: 300, payment_type: "condo_fee",
                  due_date: Date.current, status: "pending", description: "Pending one")
    summary = Payment.financial_summary(scope)
    assert_equal 100, summary[:collected_total].to_f
    assert_equal 300, summary[:pending_total].to_f
    assert_equal 25.0, summary[:collection_rate]
  end
end
