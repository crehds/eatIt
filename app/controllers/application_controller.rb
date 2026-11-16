class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :resolve_space

  private

  # Requests without a token work on the public demo data. The owner token opens the
  # owner's private space. Any other token is rejected instead of falling back to the demo.
  def resolve_space
    @demo = true
    return if request.authorization.blank?

    if authenticate_with_http_token { |token, _options| owner_token?(token) }
      @demo = false
    else
      render json: { error: "Invalid token" }, status: :unauthorized
    end
  end

  def owner_token?(token)
    expected = Rails.configuration.x.owner_api_token
    expected.present? && ActiveSupport::SecurityUtils.secure_compare(token, expected)
  end

  def products_scope
    Product.where(demo: @demo)
  end

  def orders_scope
    Order.where(demo: @demo)
  end
end
