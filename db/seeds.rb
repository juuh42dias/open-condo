# Idempotent seeds: safe to re-run (`kamal app exec "bin/rails db:seed"`).
# Records are found by their natural keys before creation.

def seed_user!(email, attrs)
  user = User.find_by(email: email)
  return user if user

  User.create!(attrs.merge(email: email)).tap do |u|
    puts "Created user: #{u.email}"
  end
end

admin_user = seed_user!("admin@condo.com",
  name: "Admin User", password: "password", password_confirmation: "password",
  role: "admin", phone: "1234567890")

owner_user = seed_user!("owner@condo.com",
  name: "John Owner", password: "password", password_confirmation: "password",
  role: "owner", phone: "9876543210")

resident_user = seed_user!("resident@condo.com",
  name: "Jane Resident", password: "password", password_confirmation: "password",
  role: "resident", phone: "5555555555")

building = Building.find_or_create_by!(name: "Sunset Towers") do |b|
  b.address = "123 Main St, City, State 12345"
  b.description = "A beautiful condominium complex with amazing amenities"
  b.total_units = 50
end
puts "Building: #{building.name}"

5.times do |i|
  Unit.find_or_create_by!(unit_number: "#{100 + i}", building: building) do |unit|
    unit.unit_type = "apartment"
    unit.bedrooms = 2
    unit.bathrooms = 2
    unit.area = 120.5
    unit.status = "available"
  end
end
puts "Units: #{building.units.count}"

owner = Owner.find_or_create_by!(user: owner_user)
puts "Owner: #{owner_user.name}"

first_unit = building.units.order(:unit_number).first
Ownership.find_or_create_by!(owner: owner, unit: first_unit) do |o|
  o.ownership_percentage = 100.0
end
puts "Ownership for unit #{first_unit.unit_number}"

Resident.find_or_create_by!(user: resident_user, unit: first_unit) do |r|
  r.move_in_date = Date.today
end
puts "Resident: #{resident_user.name}"

first_unit.update!(status: "occupied") unless first_unit.status == "occupied"

[
  { name: "Swimming Pool", description: "Olympic-size swimming pool with lounge area", capacity: 30, hourly_rate: 25.0 },
  { name: "BBQ Area", description: "Outdoor barbecue area with seating", capacity: 20, hourly_rate: 15.0 },
  { name: "Gym", description: "Fully equipped fitness center", capacity: 15, hourly_rate: 10.0 }
].each do |area_data|
  CommonArea.find_or_create_by!(name: area_data[:name], building: building) do |area|
    area.assign_attributes(area_data.except(:name))
  end
end
puts "Common areas: #{building.common_areas.count}"

MaintenanceRequest.where(
  user: resident_user, unit: first_unit, title: "Leaky faucet in kitchen"
).first_or_create! do |mr|
  mr.description = "The kitchen faucet is dripping and needs to be repaired as soon as possible."
  mr.priority = "medium"
  mr.status = "pending"
end

Notice.where(
  building: building, title: "Building Maintenance Notice"
).first_or_create! do |notice|
  notice.user = admin_user
  notice.content = "Please be advised that elevator maintenance will be conducted this weekend. Service may be interrupted."
  notice.priority = "high"
  notice.published_at = Time.current
  notice.expires_at = 1.week.from_now
end

# Balanced Starter Pack samples (best-practice modules)
Package.where(unit: first_unit, tracking_code: "BR123456789").first_or_create! do |package|
  package.recipient_name = resident_user.name
  package.sender = "Amazon"
  package.carrier = "Correios"
  package.notes = "Left in locker A1"
end

Violation.where(unit: first_unit, title: "Noise after quiet hours").first_or_create! do |violation|
  violation.reported_by = admin_user
  violation.description = "Loud music reported after 10pm on two consecutive nights."
  violation.violation_type = "noise"
  violation.severity = "medium"
  violation.fine_amount = 50.0
end

Poll.where(building: building, title: "Should we renovate the playground?").first_or_create! do |poll|
  poll.user = admin_user
  poll.description = "Vote on the 2026 playground renovation proposal."
  poll.closes_at = 2.weeks.from_now
  poll.poll_options_attributes = [{ text: "Yes, renovate" }, { text: "No, keep as is" }, { text: "Needs more info" }]
end

puts "Seed data ensured successfully!"
