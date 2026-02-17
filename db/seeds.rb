# Create default admin user
admin_user = User.create!(
  name: "Admin User",
  email: "admin@condo.com",
  password: "password",
  password_confirmation: "password",
  role: "admin",
  phone: "1234567890"
)

puts "Created admin user: #{admin_user.email}"

# Create a sample building
building = Building.create!(
  name: "Sunset Towers",
  address: "123 Main St, City, State 12345",
  description: "A beautiful condominium complex with amazing amenities",
  total_units: 50
)

puts "Created building: #{building.name}"

# Create sample units
5.times do |i|
  unit = Unit.create!(
    unit_number: "#{100 + i}",
    building: building,
    unit_type: "apartment",
    bedrooms: 2,
    bathrooms: 2,
    area: 120.5,
    status: "available"
  )
  puts "Created unit: #{unit.unit_number}"
end

# Create sample owner
owner_user = User.create!(
  name: "John Owner",
  email: "owner@condo.com",
  password: "password",
  password_confirmation: "password",
  role: "owner",
  phone: "9876543210"
)

owner = Owner.create!(user: owner_user)
puts "Created owner: #{owner_user.name}"

# Create ownership
first_unit = building.units.first
Ownership.create!(
  owner: owner,
  unit: first_unit,
  ownership_percentage: 100.0
)
puts "Created ownership for unit #{first_unit.unit_number}"

# Create sample resident
resident_user = User.create!(
  name: "Jane Resident",
  email: "resident@condo.com",
  password: "password",
  password_confirmation: "password",
  role: "resident",
  phone: "5555555555"
)

resident = Resident.create!(
  user: resident_user,
  unit: first_unit,
  move_in_date: Date.today
)
puts "Created resident: #{resident_user.name}"

# Update unit status to occupied
first_unit.update!(status: "occupied")

# Create common areas
common_areas = [
  {
    name: "Swimming Pool",
    description: "Olympic-size swimming pool with lounge area",
    capacity: 30,
    hourly_rate: 25.0
  },
  {
    name: "BBQ Area",
    description: "Outdoor barbecue area with seating",
    capacity: 20,
    hourly_rate: 15.0
  },
  {
    name: "Gym",
    description: "Fully equipped fitness center",
    capacity: 15,
    hourly_rate: 10.0
  }
]

common_areas.each do |area_data|
  common_area = CommonArea.create!(
    building: building,
    **area_data
  )
  puts "Created common area: #{common_area.name}"
end

# Create sample maintenance request
maintenance_request = MaintenanceRequest.create!(
  user: resident_user,
  unit: first_unit,
  title: "Leaky faucet in kitchen",
  description: "The kitchen faucet is dripping and needs to be repaired as soon as possible.",
  priority: "medium",
  status: "pending"
)
puts "Created maintenance request: #{maintenance_request.title}"

# Create sample notice
notice = Notice.create!(
  user: admin_user,
  building: building,
  title: "Building Maintenance Notice",
  content: "Please be advised that elevator maintenance will be conducted this weekend. Service may be interrupted.",
  priority: "high",
  published_at: Time.current,
  expires_at: 1.week.from_now
)
puts "Created notice: #{notice.title}"

puts "Seed data created successfully!"
