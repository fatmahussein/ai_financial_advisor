module HubspotHelper
 def hubspot_connected?(user)
    user.hubspot_access_token.present? && user.hubspot_token_expires_at.future?
 end
end
