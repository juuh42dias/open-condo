class Notice < ApplicationRecord
  PRIORITIES = %w[low medium high urgent].freeze

  belongs_to :user
  belongs_to :building

  validates :title, presence: true, length: { minimum: 3 }
  validates :content, presence: true, length: { minimum: 10 }
  validates :priority, presence: true, inclusion: { in: PRIORITIES }
  validates :published_at, presence: true

  scope :ordered, -> { order(published_at: :desc) }
  scope :by_priority, -> { order(Arel.sql("CASE priority WHEN 'urgent' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 WHEN 'low' THEN 4 END")) }

  def expired?
    expires_at && expires_at < Time.current
  end

  def active?
    !expired?
  end

  def self.active
    where("expires_at IS NULL OR expires_at > ?", Time.current)
  end

  def priority_label
    priority.to_s.capitalize
  end
end
