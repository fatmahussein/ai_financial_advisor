class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    auth = request.env['omniauth.auth']

    if auth.nil?
      Rails.logger.error 'Omniauth auth is NIL!'
      return redirect_to root_path, alert: 'Google login failed. Please try again.'
    end

    @user = User.from_google(auth)

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      flash[:notice] = 'Signed in!'
    else
      redirect_to root_path, alert: 'Something went wrong.'
    end
  end
end
