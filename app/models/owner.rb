class Owner < ApplicationRecord
  belongs_to :user
  has_many :ownerships, dependent: :destroy
  has_many :units, through: :ownerships
end
