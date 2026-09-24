Rails.application.routes.draw do
  devise_for :users

  root to: "dashboard#index"
  get "dashboard", to: "dashboard#index"

  # Buildings, their units and common areas
  resources :buildings do
    resources :units, except: :index
    resources :common_areas, except: %i[index show] do
      resources :reservations, only: %i[new create]
    end
  end

  # Browse all common areas across buildings
  resources :common_areas, only: %i[index show]

  # Reservations
  resources :reservations, only: %i[index show destroy] do
    member do
      patch :confirm
      patch :cancel
    end
  end

  # Maintenance requests
  resources :maintenance_requests do
    member do
      patch :start
      patch :complete
      patch :cancel
    end
  end

  # Visitor management
  resources :visitors, only: %i[index show new create destroy] do
    member do
      patch :approve
      patch :reject
      patch :check_in
      patch :check_out
    end
  end

  # Notices / announcements
  resources :notices

  # Payments / dues
  resources :payments, only: %i[index show new create] do
    member do
      patch :mark_paid
      patch :mark_pending
    end
    collection do
      post :generate_monthly
      post :apply_late_fees
      post :mark_overdue
    end
  end

  # Package / parcel tracking (Condo Control-style concierge log)
  resources :packages, only: %i[index show new create destroy] do
    member do
      patch :notify_pickup
      patch :mark_picked_up
      patch :mark_returned
    end
  end

  # Violation tracking + fines
  resources :violations do
    member do
      patch :acknowledge
      patch :resolve
      patch :dismiss
      post :convert_to_fine
    end
  end

  # Polls / surveys / e-voting
  resources :polls do
    member do
      post :vote
      patch :close
      patch :reopen
    end
  end

  # User management (admin only)
  resources :users, only: %i[index show new create edit update destroy]

  # Health check for Kamal / load balancers
  get "/_health", to: ->(_env) { [200, { "content-type" => "text/html" }, ["I'm alive"]] }

  mount ActionCable.server, at: "/cable"
end
