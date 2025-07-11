class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
        :omniauthable, omniauth_providers: [:google_oauth2]

    def self.from_google(auth)
      user = where(email: auth.info.email).first_or_initialize
      user.update(
        name: auth.info.name,
        provider: auth.provider,
        uid: auth.uid,
        google_token: auth.credentials.token,
        google_refresh_token: auth.credentials.refresh_token,
        token_expires_at: Time.at(auth.credentials.expires_at)
      )
      user
    end

end
