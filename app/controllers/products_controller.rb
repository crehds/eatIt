class ProductsController < ApplicationController
  def index
    @products = Product.all
    render json: @products, status: :ok
  end

  def show
    @product = Product.find(params[:id])
    render json: @product, status: :ok
  end

  def new
    @product = Product.new
    render json: @product
  end
end
