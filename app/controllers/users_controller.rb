# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user,
                only: %i[show edit update destroy edit_image update_image]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show; end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit; end

  def edit_image
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def update_image
    respond_to do |format|
      if @user.update(image_params)
        format.html do
          redirect_to @user, notice: 'User\'s image was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render @user }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def transactions
    redirect_to user_path(@user) unless current_user
    @made_transactions = Transaction.where from_user: current_user
    @received_transactions = Transaction.where to_user: current_user
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new user_params
    respond_to do |format|
      if @user.save
        UserMailer.welcome_mail(@user).deliver_later
        session[:user_id] = @user.id
        format.html do
          redirect_to @user, notice: 'User was successfully created.'
        end
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html do
          redirect_to @user, notice: 'User was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html do
        redirect_to users_url, notice: 'User was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  def upgrade
    @user = User.find(params[:user_id])
    @user.admin!
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def downgrade
    @user = User.find(params[:user_id])
    @user.user!
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def user_params
    user_params = params.require(:user).permit(
      :mail, :name, :password, :username,
      :password_confirmation
    )
    user_params[:role] = :user
    user_params[:amount] = 0
    user_params
  end

  def image_params
    params.require(:user).permit(:image)
  end
end
