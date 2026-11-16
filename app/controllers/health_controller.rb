class HealthController < ApplicationController
  # Railway's health check must work whatever Authorization header arrives.
  skip_before_action :resolve_space

  def health
    render json: { api: "OK" }, status: :ok
  end
end
