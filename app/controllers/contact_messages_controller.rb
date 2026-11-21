class ContactMessagesController < ApplicationController
  def new
    @message = ContactMessage.new(name: current_user&.name, email: current_user&.email)
  end

  def create
    @message = ContactMessage.new(params.require(:contact_message).permit(:name, :email, :subject, :message))
    if @message.save
      redirect_to root_path, notice: "Повідомлення надіслано. Ми збережемо його для адміністратора."
    else
      render :new, status: :unprocessable_entity
    end
  end
end
