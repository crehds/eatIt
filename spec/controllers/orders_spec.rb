require "rails_helper"

RSpec.describe OrdersController, type: :controller do
  describe "GET #index" do
    subject { get :index }

    it { should have_http_status(:ok) }
  end

  describe "POST #create" do
    let!(:order) { attributes_for(:order) }
    it do
      should permit(:delivery_address).for(:create, params: { order: }).on(:order)
    end
  end

  describe "PATCH #update" do
    before do
      create(:order, id: 1)
    end

    let!(:order) { attributes_for(:order) }

    it do
      params = {
        id: 1,
        order:
      }

      should permit(:delivery_address).for(:update, params:).on(:order)
    end
  end
end
