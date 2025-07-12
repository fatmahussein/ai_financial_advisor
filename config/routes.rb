Rails.application.routes.draw do
  get "contacts/index"
  get '/hubspot/connect', to: 'hubspot#connect', as: :hubspot_connect
  get '/hubspot/callback', to: 'hubspot#callback', as: :hubspot_callback

  resources :contacts, only: [:index]

  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # authenticated page
  get "home/index"
  # Defines the root path route ("/")
  root to: "home#index"
  get 'sync_emails', to: 'home#sync_emails'
  get '/hubspot/contacts', to: 'hubspot#contacts'
  get 'hubspot/sync_contacts', to: 'hubspot#sync_contacts'  
  post '/hubspot/sync_contacts', to: 'hubspot#sync_contacts', as: :sync_hubspot_contacts

end
