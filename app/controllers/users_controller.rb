class UsersController < ApplicationController
  before_action :require_admin!
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @users = User.ordered.includes(:owner, :resident)
    @users = @users.where(role: params[:role]) if params[:role].present?
  end

  def show; end

  def new
    @user = User.new(role: "resident")
    @selected_unit_id = nil
    load_units
  end

  def create
    @user = User.new(user_params)

    if @user.save
      sync_relationships(@user)
      redirect_to @user, notice: "User created."
    else
      load_units
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @selected_unit_id = @user.resident&.unit_id || @user.owner&.units&.first&.id
    load_units
  end

  def update
    attributes = user_params
    attributes = attributes.except(:password, :password_confirmation) if attributes[:password].blank?

    if @user.update(attributes)
      sync_relationships(@user)
      redirect_to @user, notice: "User updated."
    else
      load_units
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to users_path, alert: "You cannot delete your own account.", status: :see_other
    else
      @user.destroy
      redirect_to users_path, notice: "User deleted.", status: :see_other
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def load_units
    @units = Unit.ordered.includes(:building)
  end

  def sync_relationships(user)
    unit_id = params.dig(:user, :unit_id).presence
    unit = Unit.find_by(id: unit_id)

    case user.role
    when "resident"
      sync_resident(user, unit)
    when "owner"
      sync_owner(user, unit)
    end
  end

  def sync_resident(user, unit)
    return unless unit

    move_in = params.dig(:user, :move_in_date).presence || Date.current
    if user.resident
      user.resident.update(unit: unit, move_in_date: move_in)
    else
      user.create_resident(unit: unit, move_in_date: move_in)
    end
  end

  def sync_owner(user, unit)
    owner = user.owner || user.create_owner
    return unless unit

    ownership = owner.ownerships.find_or_initialize_by(unit: unit)
    ownership.ownership_percentage = params.dig(:user, :ownership_percentage).presence || 100
    ownership.save
  end

  def user_params
    params.require(:user).permit(:name, :email, :phone, :role, :password, :password_confirmation)
  end
end
