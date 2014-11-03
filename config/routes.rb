Rails.application.routes.draw do
  root 'static#index'

  match '/about', to: 'static#about', via: 'get'

  # Devise routes
  devise_for :users, path: 'user', skip: [:sessions, :registrations]
  as :user do
    # :sessions
    get 'sign_in' => 'devise/sessions#new', as: :new_user_session
    post 'sign_in' => 'devise/sessions#create', as: :user_session
    delete 'sign_out' => 'devise/sessions#destroy', as: :destroy_user_session
    # :registrations
    get 'settings/delete_account' => 'devise/registrations#cancel', as: :cancel_user_registration
    post '/user/create' => 'devise/registrations#create', as: :user_registration
    get '/sign_up' => 'devise/registrations#new', as: :new_user_registration
    get '/settings/account' => 'devise/registrations#edit', as: :edit_user_registration
    patch '/settings/account' => 'devise/registrations#update'
    put '/settings/account' => 'devise/registrations#update'
    delete '/settings/account' => 'devise/registrations#destroy'
  end

  match '/settings/profile', to: 'user#edit', via: 'get', as: :edit_user_profile
  
  match '/user/:username', to: 'user#show', via: 'get'
  match '/@:username', to: 'user#show', via: 'get', as: :show_user_profile_at
  match '/:username', to: 'user#show', via: 'get', as: :show_user_profile
end