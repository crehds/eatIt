class ApplicationController < ActionController::API
  class NotItemsError < StandardError; end

  rescue_from NotItemsError do
    render json: { message: "The order not has items to save" }, status: :unprocessable_entity
  end
end
