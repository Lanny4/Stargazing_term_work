class RegistrationsController < ApplicationController
  def new
    redirect_to root_path and return if signed_in?
    @user = User.new
  end

  def create
    redirect_to root_path and return if signed_in?
    @user = User.new(params.require(:user).permit(:name, :email, :password, :password_confirmation))
    if @user.save
      reset_session
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Вітаємо у Stargazing! Ваш обліковий запис створено."
    else
      render :new, status: :unprocessable_entity
    end
  end
end
