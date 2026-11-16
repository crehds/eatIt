Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # The API has no frontend: the root shows its documentation.
  root to: redirect("/api-docs/index.html")

  # health endpoint
  get "/health", to: "health#health"

  resources :products
  resources :orders
end
