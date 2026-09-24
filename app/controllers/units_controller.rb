class UnitsController < ApplicationController
  before_action :set_building
  before_action :set_unit, only: %i[show edit update destroy]
  before_action :require_staff!, except: %i[show]

  def show; end

  def new
    @unit = @building.units.new(status: "available", unit_type: "apartment", bedrooms: 1, bathrooms: 1)
  end

  def create
    @unit = @building.units.new(unit_params)

    if @unit.save
      redirect_to [@building, @unit], notice: "Unit was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @unit.update(unit_params)
      redirect_to [@building, @unit], notice: "Unit was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @unit.destroy
    redirect_to @building, notice: "Unit was deleted.", status: :see_other
  end

  private

  def set_building
    @building = Building.find(params[:building_id])
  end

  def set_unit
    @unit = @building.units.find(params[:id])
  end

  def unit_params
    params.require(:unit).permit(:unit_number, :unit_type, :bedrooms, :bathrooms, :area, :status)
  end
end
