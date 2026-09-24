class PollsController < ApplicationController
  before_action :set_poll, only: %i[show edit update destroy vote close reopen]
  before_action :authorize_poll_access!, only: %i[show vote]
  before_action :require_staff!, only: %i[new create edit update destroy close reopen]

  def index
    @polls = visible_polls.ordered.includes(:building, :poll_options)
  end

  def show
    @vote = @poll.vote_for(current_user)
    @results = @poll.results
  end

  def new
    @poll = Poll.new(status: "open")
    3.times { @poll.poll_options.build }
  end

  def create
    @poll = current_user.polls.new(poll_params)

    if @poll.save
      redirect_to @poll, notice: "Poll published."
    else
      (3 - @poll.poll_options.size).times { @poll.poll_options.build } if @poll.poll_options.size < 3
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @poll.update(poll_params)
      redirect_to @poll, notice: "Poll updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def vote
    option = @poll.poll_options.find(params[:poll_option_id])

    if @poll.voted_by?(current_user)
      return redirect_to @poll, alert: "You have already voted in this poll."
    end

    @poll.votes.create!(user: current_user, poll_option: option)
    redirect_to @poll, notice: "Vote counted."
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e
    redirect_to @poll, alert: "Could not count vote: #{e.message}"
  end

  def close
    @poll.close!
    redirect_to @poll, notice: "Poll closed.", status: :see_other
  end

  def reopen
    @poll.reopen!
    redirect_to @poll, notice: "Poll reopened.", status: :see_other
  end

  def destroy
    @poll.destroy
    redirect_to polls_path, notice: "Poll deleted.", status: :see_other
  end

  private

  def visible_polls
    return Poll.all if staff_user?

    building_ids = current_user.units.select(:building_id)
    Poll.where(building_id: building_ids)
  end

  def set_poll
    @poll = Poll.find(params[:id])
  end

  def authorize_poll_access!
    return if staff_user?
    return if current_user.units.exists?(building_id: @poll.building_id)

    redirect_to root_path, alert: "You are not authorized to view this poll."
  end

  def poll_params
    params.require(:poll).permit(:title, :description, :building_id, :closes_at,
                                 poll_options_attributes: %i[id text _destroy])
  end
end
