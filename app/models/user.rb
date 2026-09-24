class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[admin manager owner resident].freeze

  has_one :owner, dependent: :destroy
  has_one :resident, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :maintenance_requests, dependent: :destroy
  has_many :notices, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :visitors, through: :resident
  has_many :reported_violations, class_name: "Violation", foreign_key: :reported_by_id, dependent: :nullify
  has_many :polls, dependent: :destroy
  has_many :votes, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2 }
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :phone, format: { with: /\A\+?\d+\z/, message: "only allows numbers" }, allow_blank: true

  scope :staff, -> { where(role: %w[admin manager]) }
  scope :ordered, -> { order(:name) }

  def self.roles
    ROLES
  end

  def admin?
    role == "admin"
  end

  def manager?
    role == "manager"
  end

  def owner?
    role == "owner"
  end

  def resident?
    role == "resident"
  end

  def staff?
    admin? || manager?
  end

  # Kept for backwards compatibility with existing views.
  def is_admin? = admin?
  def is_manager? = manager?
  def is_owner? = owner?
  def is_resident? = resident?

  def role_label
    role.to_s.capitalize
  end

  def initials
    name.to_s.split.map { |part| part[0] }.join.upcase.first(2)
  end

  # Units the user can act on (owned units, or the unit they live in).
  def units
    if owner?
      owner_record = owner || Owner.find_by(user_id: id)
      owner_record ? owner_record.units : Unit.none
    elsif resident?
      resident_record = resident || Resident.find_by(user_id: id)
      resident_record ? Unit.where(id: resident_record.unit_id) : Unit.none
    else
      Unit.all
    end
  end
end
