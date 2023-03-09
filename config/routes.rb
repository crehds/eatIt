Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # health endpoint
  get "/health", to: "health#health"

  resources :products
  get "/orders", to: "orders#index"
  get "/orders/:id", to: "orders#show"
end
