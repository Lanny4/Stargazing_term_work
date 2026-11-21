class SessionsController < ApplicationController
  def new
    redirect_to root_path if signed_in?
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    if user&.authenticate(params[:password].to_s)
      saved_cart = cart_hash
      reset_session
      session[:user_id] = user.id
      session[:cart] = saved_cart
      redirect_to root_path, notice: "Ви успішно увійшли"
    else
      flash.now[:alert] = "Неправильний email або пароль"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Ви вийшли з облікового запису"
  end
end
