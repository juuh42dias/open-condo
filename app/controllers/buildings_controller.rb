class BuildingsController < ApplicationController
  before_action :set_building, only: %i[show edit update destroy]
  before_action :require_staff!, except: %i[index show]

  def index
    @buildings = Building.ordered.includes(:units)
  end

  def show
    @units = @building.units.ordered
    @common_areas = @building.common_areas.ordered
    @notices = @building.notices.active.ordered.limit(5)
  end

  def new
    @building = Building.new(total_units: 1)
  end

  def create
    @building = Building.new(building_params)

    if @building.save
      redirect_to @building, notice: "Building was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @building.update(building_params)
      redirect_to @building, notice: "Building was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @building.destroy
    redirect_to buildings_path, notice: "Building was deleted.", status: :see_other
  end

  private

  def set_building
    @building = Building.find(params[:id])
  end

  def building_params
    params.require(:building).permit(:name, :address, :description, :total_units)
  end
end
