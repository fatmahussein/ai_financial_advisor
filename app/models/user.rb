class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
        :omniauthable, omniauth_providers: [:google_oauth2]

  def self.from_google(auth)
  user = find_or_initialize_by(email: auth.info.email)

  user.assign_attributes(
    name: auth.info.name,
    provider: auth.provider,
    uid: auth.uid,
    google_token: auth.credentials.token,
    google_refresh_token: auth.credentials.refresh_token || user.google_refresh_token,
    token_expires_at: Time.at(auth.credentials.expires_at)
  )

  # Set a random password if it's a new user (OAuth)
  user.password = SecureRandom.hex(15) if user.encrypted_password.blank?

  user.save!
  user
end



end
