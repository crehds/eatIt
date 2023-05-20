class OrdersController < ApplicationController
  rescue_from NotItemsError, with: :render_not_items_error

  def index
    @orders = Order.all
    render json: @orders, status: :ok
  end

  def show
    @order = Order.find(params[:id])
    render json: @order, status: :ok
  end

  def create
    Order.transaction do
      @order = Order.new(order_params)
      if @order.save
        raise NotItemsError if params[:items].blank?

        params[:items].each do |item|
          product = Product.find(item[:id])
          @order.order_details.create!(product:, quantity: item[:quantity])
        end

        render json: @order, status: :created
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    end
  end

  def update
    @order = Order.find(params[:id])
    if @order.update(order_params)
      render json: @order, status: :created
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    render json: { message: "Order deleted" }, status: :ok
  end

  private

  def order_params
    params.require(:order).permit(:delivery_address)
  end

  def render_not_items_error
    render json: { message: "The order not has items to save" }, status: :unprocessable_entity
  end
end
