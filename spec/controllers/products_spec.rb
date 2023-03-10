require "rails_helper"

RSpec.describe ProductsController, type: :controller do
  describe  "GET #index" do
    subject { get :index }

    it { should have_http_status(:ok) }
  end

  describe "POST #create" do
    let(:product) { attributes_for(:product_params) }
    it do
      should permit(:name, :description, :price, :category).for(:create,
                                                                params: { product: }).on(:product)
    end
  end

  describe "PATCH #update" do
    before do
      create(:product, id: 1)
    end

    let!(:product) { attributes_for(:product_params) }

    it do
      params = {
        id: 1,
        product:
      }

      should permit(:name, :description, :category, :price).for(:update, params:).on(:product)
    end
  end
end
