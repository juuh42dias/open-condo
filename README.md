# OpenCondo - Condominium Management System

A comprehensive Ruby on Rails application for managing residential condominium complexes with the most common features needed for efficient property management.

## Features

### ✅ Completed Features

- **User Authentication** - Role-based access (Admin, Owner, Resident, Manager)
- **Building Management** - Multiple building support with unit management
- **Unit Management** - Track unit types, occupancy status, and specifications
- **Owner-Resident Relationships** - Proper ownership tracking and resident assignments
- **Dashboard** - Overview with key metrics and quick access to main features
- **Navigation** - Responsive navigation with role-based menu items

### 🔄 Core Models Implemented

- **Buildings** - Multiple condominium support
- **Units** - Individual unit management with status tracking
- **Users** - Authentication with Devise and role-based permissions
- **Owners** - Property ownership management with percentage tracking
- **Residents** - Resident information and unit assignments
- **Maintenance Requests** - Issue tracking and resolution management
- **Notices** - Community announcements and building communications
- **Payments** - Financial tracking and dues management
- **Common Areas** - Shared facility management
- **Reservations** - Common area booking system
- **Visitors** - Visitor registration and approval system

## 🚀 Getting Started

### Prerequisites

- Ruby 3.4.4
- Rails 7.2+
- PostgreSQL
- Node.js (for asset compilation)

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd open_condo
   ```

2. **Install dependencies**

   ```bash
   bundle install
   ```

3. **Database setup**

   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Start the server**

   ```bash
   rails server
   ```

5. **Access the application**
   - Open your browser to `http://localhost:3000`
   - Sign in with seed data:
     - **Admin**: admin@condo.com / password
     - **Owner**: owner@condo.com / password
     - **Resident**: resident@condo.com / password

## 👥 User Roles

### Admin

- Full system access
- User management
- Building management
- Financial oversight
- System configuration

### Owner

- Manage owned properties
- View maintenance requests
- Access financial reports for owned units
- Manage residents

### Resident

- View unit information
- Submit maintenance requests
- Book common areas
- View community notices
- Register visitors

### Manager

- Day-to-day operations
- Process maintenance requests
- Manage common areas
- Handle visitor approvals

## 🏗️ System Architecture

### Models & Relationships

```
Building
├── Units
│   ├── Residents
│   ├── MaintenanceRequests
│   └── Payments
├── CommonAreas
│   └── Reservations
└── Notices

User
├── Owner (if owner role)
│   └── Ownerships → Units
├── Resident (if resident role)
│   └── Unit
└── Various permissions based on role
```

### Key Features by Module

#### 🏢 Building Management

- Multiple building support
- Unit inventory and status tracking
- Occupancy management
- Building specifications

#### 🔧 Maintenance System

- Request submission and tracking
- Priority levels (Low, Medium, High, Urgent)
- Status management (Pending, In Progress, Completed)
- Communication tracking

#### 📢 Notices & Communications

- Building announcements
- Priority-based notices
- Expiration dates
- Targeted communications

#### 💰 Financial Management

- Payment tracking
- Due management
- Multiple payment types
- Status tracking

#### 🏊 Common Areas & Reservations

- Facility management
- Booking system
- Time slot management
- Cost calculation

#### 👥 Visitor Management

- Visitor registration
- Approval workflow
- Visit tracking
- Security integration

## 🔧 Development

### Running Tests

```bash
rails test
```

### Console Access

```bash
rails console
```

### Database Management

```bash
rails db:migrate    # Run migrations
rails db:seed      # Load seed data
rails db:reset     # Reset database
```

## 📋 Next Steps / TODO

### Medium Priority Features

- [ ] Enhanced maintenance request workflow
- [ ] Visitor pre-registration system
- [ ] Automated notice distribution
- [ ] Payment gateway integration

### Low Priority Features

- [ ] Mobile app API
- [ ] Advanced reporting
- [ ] Email notifications
- [ ] File attachments for requests

## 🛠️ Technical Stack

- **Backend**: Ruby on Rails 7.2
- **Database**: PostgreSQL
- **Authentication**: Devise
- **Frontend**: ERB templates with custom CSS
- **Testing**: Rails Test Suite
- **Code Quality**: RuboCop, Brakeman security scanner

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions, please open an issue in the repository or contact the development team.

---

**Note**: This is a comprehensive condominium management system designed to handle the most common needs of residential property management. The system is built with scalability and user experience in mind.
