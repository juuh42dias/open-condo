class ReservationsController < ApplicationController
  before_action :set_reservation, only: %i[show confirm cancel destroy]
  before_action :authorize_staff!, only: %i[confirm]
  before_action :authorize_reservation_access!, only: %i[show cancel destroy]

  def index
    @reservations = scope_for_index.ordered.includes(:user, common_area: :building)
  end

  def show; end

  def new
    @building = Building.find(params[:building_id])
    @common_area = @building.common_areas.find(params[:common_area_id])
    @reservation = @common_area.reservations.new(start_time: 1.day.from_now.change(hour: 10), end_time: 1.day.from_now.change(hour: 12))
  end

  def create
    @building = Building.find(params[:building_id])
    @common_area = @building.common_areas.find(params[:common_area_id])
    @reservation = @common_area.reservations.new(reservation_params)
    @reservation.user = current_user
    @reservation.status = "pending"

    if @reservation.save
      redirect_to @reservation, notice: "Reservation requested. You will be notified once it is confirmed."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    @reservation.confirm!
    redirect_to @reservation, notice: "Reservation confirmed.", status: :see_other
  end

  def cancel
    @reservation.cancel!
    redirect_to @reservation, notice: "Reservation cancelled.", status: :see_other
  end

  def destroy
    @reservation.destroy
    redirect_to reservations_path, notice: "Reservation removed.", status: :see_other
  end

  private

  def scope_for_index
    staff_user? ? Reservation.all : Reservation.for_user(current_user)
  end

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def authorize_staff!
    return if staff_user?

    redirect_to root_path, alert: "You are not authorized to perform this action."
  end

  def authorize_reservation_access!
    return if staff_user? || @reservation.user == current_user

    redirect_to root_path, alert: "You are not authorized to view this reservation."
  end

  def reservation_params
    params.require(:reservation).permit(:start_time, :end_time)
  end
end
