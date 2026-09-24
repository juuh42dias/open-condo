require "test_helper"

class ViolationTest < ActiveSupport::TestCase
  def setup
    @building = Building.create!(name: "T1", address: "A", total_units: 10)
    @unit = Unit.create!(unit_number: "101", building: @building, unit_type: "apartment",
                         bedrooms: 2, bathrooms: 1, area: 80, status: "occupied")
    @reporter = User.create!(name: "Staff", email: "staff-v@example.com", password: "password123",
                             role: "manager")
    @resident_user = User.create!(name: "Res", email: "res-v@example.com", password: "password123",
                                  role: "resident")
    Resident.create!(user: @resident_user, unit: @unit, move_in_date: Date.current)
  end

  test "requires title description and enums" do
    v = Violation.new(unit: @unit, reported_by: @reporter, title: "Hi",
                      description: "short", violation_type: "bogus")
    assert_not v.valid?
    v.title = "Noise complaint"
    v.description = "Loud music after quiet hours, multiple nights."
    v.violation_type = "noise"
    v.severity = "high"
    assert v.valid?
  end

  test "acknowledge and resolve" do
    v = Violation.create!(unit: @unit, reported_by: @reporter, title: "Parking issue",
                          description: "Car blocking garage entrance repeatedly.", violation_type: "parking")
    assert v.open?
    v.acknowledge!
    assert_equal "acknowledged", v.status
    v.resolve!
    assert v.resolved?
  end

  test "convert_to_fine creates payment" do
    v = Violation.create!(unit: @unit, reported_by: @reporter, title: "Trash violation",
                          description: "Trash left in hallway for several days.", violation_type: "trash",
                          fine_amount: 75.0)
    assert_difference("Payment.count", 1) do
      payment = v.convert_to_fine!
      assert_equal 75.0, payment.amount.to_f
    end
    assert_equal "fined", v.reload.status
  end

  test "convert_to_fine requires positive amount" do
    v = Violation.create!(unit: @unit, reported_by: @reporter, title: "Minor",
                          description: "Minor hallway obstruction noticed today.", violation_type: "other",
                          fine_amount: 0)
    assert_raises(ActiveRecord::RecordInvalid) { v.convert_to_fine! }
  end
end
