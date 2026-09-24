class Vote < ApplicationRecord
  belongs_to :poll
  belongs_to :poll_option, counter_cache: :votes_count
  belongs_to :user

  validates :user_id, uniqueness: { scope: :poll_id, message: "has already voted in this poll" }
  validate :option_belongs_to_poll
  validate :poll_is_open

  private

  def option_belongs_to_poll
    return if poll_option.nil? || poll.nil?
    return if poll_option.poll_id == poll.id

    errors.add(:poll_option, "must belong to the same poll")
  end

  def poll_is_open
    return if poll.nil?
    return if poll.open?

    errors.add(:poll, "is closed")
  end
end
