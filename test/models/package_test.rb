require "test_helper"

class PackageTest < ActiveSupport::TestCase
  def setup
    @building = Building.create!(name: "T1", address: "A", total_units: 10)
    @unit = Unit.create!(unit_number: "101", building: @building, unit_type: "apartment",
                         bedrooms: 2, bathrooms: 1, area: 80, status: "occupied")
  end

  test "requires recipient and valid status" do
    p = Package.new(unit: @unit, recipient_name: "")
    assert_not p.valid?
    p.recipient_name = "Jane"
    p.status = "bogus"
    assert_not p.valid?
    p.status = "received"
    assert p.valid?
  end

  test "transitions notify and pickup" do
    p = Package.create!(unit: @unit, recipient_name: "Jane")
    assert_equal "received", p.status
    assert p.awaiting_pickup?
    p.notify!
    assert_equal "notified", p.status
    p.mark_picked_up!
    assert p.picked_up?
    assert_not p.awaiting_pickup?
  end

  test "awaiting_pickup scope" do
    Package.create!(unit: @unit, recipient_name: "Anna")
    b = Package.create!(unit: @unit, recipient_name: "Bob Smith")
    b.mark_picked_up!
    assert_equal 1, Package.where(unit_id: @unit.id).awaiting_pickup.count
  end
end
