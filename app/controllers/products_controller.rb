class ProductsController < ApplicationController
  def index
    @products = products_scope
    render json: @products, status: :ok
  end

  def show
    @product = products_scope.find(params[:id])
    render json: @product, status: :ok
  end

  def create
    @product = products_scope.new(product_params)
    if @product.save
      render json: @product, status: :created
    else
      render json: @product.errors, status: :unprocessable_content
    end
  end

  def update
    @product = products_scope.find(params[:id])
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_content
    end
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :category)
  end

  def destroy
    @product = products_scope.find(params[:id])
    @product.destroy
    render json: { message: "Product deleted" }, status: :ok
  end
end
