class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  protect_from_forgery with: :exception
  helper HubspotHelper

  def after_sign_in_path_for(_resource)
    home_index_path
  end
end
