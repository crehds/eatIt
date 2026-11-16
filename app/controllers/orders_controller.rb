class OrdersController < ApplicationController
  rescue_from NotItemsError, with: :render_not_items_error

  def index
    @orders = orders_scope
    render json: @orders, status: :ok
  end

  def show
    @order = orders_scope.find(params[:id])
    render json: @order, status: :ok
  end

  def create
    Order.transaction do
      @order = orders_scope.new(order_params)
      if @order.save
        raise NotItemsError if params[:items].blank?

        params[:items].each do |item|
          product = products_scope.find(item[:id])
          @order.order_details.create!(product:, quantity: item[:quantity])
        end

        render json: @order, status: :created
      else
        render json: @order.errors, status: :unprocessable_content
      end
    end
  end

  def update
    @order = orders_scope.find(params[:id])
    if @order.update(order_params)
      render json: @order, status: :created
    else
      render json: @order.errors, status: :unprocessable_content
    end
  end

  def destroy
    @order = orders_scope.find(params[:id])
    @order.destroy

    render json: { message: "Order deleted" }, status: :ok
  end

  private

  def order_params
    params.require(:order).permit(:delivery_address)
  end

  def render_not_items_error
    render json: { message: "The order not has items to save" }, status: :unprocessable_content
  end
end
