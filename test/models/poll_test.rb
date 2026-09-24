require "test_helper"

class PollTest < ActiveSupport::TestCase
  def setup
    @building = Building.create!(name: "T1", address: "A", total_units: 10)
    @staff = User.create!(name: "Staff", email: "staff-p@example.com", password: "password123", role: "admin")
    @voter = User.create!(name: "Voter", email: "voter-p@example.com", password: "password123", role: "resident")
  end

  def build_poll
    Poll.new(building: @building, user: @staff, title: "Renovate playground?",
             poll_options_attributes: [{ text: "Yes" }, { text: "No" }])
  end

  test "requires at least two options" do
    p = Poll.new(building: @building, user: @staff, title: "Single?",
                 poll_options_attributes: [{ text: "Only" }])
    assert_not p.valid?
    assert_includes p.errors[:poll_options].join, "at least two"
  end

  test "vote once and count results" do
    poll = build_poll
    assert poll.save
    yes = poll.poll_options.find_by(text: "Yes")
    no = poll.poll_options.find_by(text: "No")

    poll.votes.create!(user: @voter, poll_option: yes)
    assert poll.voted_by?(@voter)
    assert_equal 1, poll.reload.total_votes

    dup = poll.votes.new(user: @voter, poll_option: no)
    assert_not dup.valid?

    results = poll.reload.results
    assert_equal 1, results.find { |r| r[:option] == yes }[:count]
    assert_equal 100.0, results.find { |r| r[:option] == yes }[:percentage]
  end

  test "closed poll rejects votes" do
    poll = build_poll
    poll.save!
    poll.close!
    vote = poll.votes.new(user: @voter, poll_option: poll.poll_options.first)
    assert_not vote.valid?
  end
end
