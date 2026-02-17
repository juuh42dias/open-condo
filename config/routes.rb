Rails.application.routes.draw do
  get "notices/Payments"
  get "visitors/index"
  get "visitors/create"
  get "visitors/show"
  get "maintenance_requests/index"
  get "maintenance_requests/create"
  get "maintenance_requests/show"
  get "maintenance_requests/update"
  get "common_areas/Reservations"
  get "common_areas/MaintenanceRequests"
  get "common_areas/Visitors"
  get "common_areas/Notices"
  get "common_areas/Payments"
  get "dashboard/index"
  devise_for :users
  
  root to: "dashboard#index"
  
  # Dashboard
  get 'dashboard', to: 'dashboard#index'
  
  # Building management
  resources :buildings do
    resources :units
    resources :common_areas do
      resources :reservations
    end
  end
  
  # User management
  resources :users, only: [:index, :show, :edit, :update]
  
  # Maintenance requests
  resources :maintenance_requests
  
  # Visitor management
  resources :visitors
  
  # Notices/Announcements
  resources :notices
  
  # Payments
  resources :payments
  
  # Health check
  get "/_health", to: -> _env {
    [200, { "content-type" => "text/html" }, ["I'm alive"]]
  }

  mount ActionCable.server, at: "/cable"
end

# request =
#   Rack::MockRequest.env_for('http://localhost:3000')
# TraceLocation.trace(format: :log) do
#   Rails.application.call(request)
# end

