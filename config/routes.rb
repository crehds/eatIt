Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # health endpoint
  get "/health", to: "health#health"

  delete "/products/:id", to: "products#destroy"

  post "/products", to: "products#create"
  patch "/products/:id", to: "products#update"

  get "/products/new", to: "products#new", as: :new_product
  get "/products", to: "products#index"
  get "/products/:id", to: "products#show", as: :product
end
