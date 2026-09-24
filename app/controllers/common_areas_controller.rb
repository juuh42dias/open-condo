class CommonAreasController < ApplicationController
  before_action :set_building, only: %i[new create edit update destroy]
  before_action :set_common_area, only: %i[show edit update destroy]
  before_action :require_staff!, except: %i[index show]

  def index
    @common_areas = CommonArea.ordered.includes(:building)
  end

  def show
    @reservations = @common_area.reservations.upcoming.limit(10)
  end

  def new
    @common_area = @building.common_areas.new(capacity: 10, hourly_rate: 0)
  end

  def create
    @common_area = @building.common_areas.new(common_area_params)

    if @common_area.save
      redirect_to [@building, @common_area], notice: "Common area was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @common_area.update(common_area_params)
      redirect_to [@building, @common_area], notice: "Common area was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @common_area.destroy
    redirect_to @building, notice: "Common area was deleted.", status: :see_other
  end

  private

  def set_building
    @building = Building.find(params[:building_id])
  end

  def set_common_area
    @common_area = CommonArea.find(params[:id])
    @building ||= @common_area.building
  end

  def common_area_params
    params.require(:common_area).permit(:name, :description, :capacity, :hourly_rate)
  end
end
