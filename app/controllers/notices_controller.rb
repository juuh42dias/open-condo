class NoticesController < ApplicationController
  before_action :set_notice, only: %i[show edit update destroy]
  before_action :require_staff!, except: %i[index show]

  def index
    @notices = (staff_user? ? Notice.all : Notice.active).by_priority.includes(:building, :user)
  end

  def show; end

  def new
    @notice = Notice.new(priority: "medium", published_at: Time.current)
  end

  def create
    @notice = current_user.notices.new(notice_params)

    if @notice.save
      redirect_to @notice, notice: "Notice published."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @notice.update(notice_params)
      redirect_to @notice, notice: "Notice updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @notice.destroy
    redirect_to notices_path, notice: "Notice deleted.", status: :see_other
  end

  private

  def set_notice
    @notice = Notice.find(params[:id])
  end

  def notice_params
    params.require(:notice).permit(:title, :content, :priority, :building_id, :published_at, :expires_at)
  end
end
