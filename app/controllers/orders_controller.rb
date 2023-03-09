class OrdersController < ApplicationController
  def index
    @orders = Order.all
    render json: @orders, status: :ok
  end

  def show
    @order = Order.find(params[:id])
    render json: @order, status: :ok
  end

  def create
    @order = Order.new(order_params)
    if @order.save
      render json: @order, status: :created
    else
      render json: @order.errors, status: :unprocessable_entity
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

  def order_params
    params.require(:order).permit(:delivery_address)
  end
end
