class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    auth = request.env['omniauth.auth']
    @user = User.find_or_create_by(email: auth.info.email) do |user|
      user.password = Devise.friendly_token[0, 20]
    end

    if auth.nil?
      Rails.logger.error 'Omniauth auth is NIL!'
      return redirect_to root_path, alert: 'Google login failed. Please try again.'
    end

    if @user
      @user.update!(
        google_access_token: auth.credentials.token,
        google_refresh_token: auth.credentials.refresh_token.presence || @user.google_refresh_token,
        google_token_expires_at: Time.at(auth.credentials.expires_at)
      )
      puts auth.credentials.inspect
      puts "Saved user? #{@user.save}"
      puts @user.errors.full_messages

      sign_in_and_redirect @user, event: :authentication
      flash[:notice] = 'Signed in!'
    else
      redirect_to root_path, alert: 'Something went wrong.'
    end
  end
end
