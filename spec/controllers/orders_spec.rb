require "rails_helper"

RSpec.describe OrdersController, type: :controller do
  describe "GET #index" do
    subject { get :index }

    it { should have_http_status(:ok) }
  end

  describe "POST #create" do
    before do
      create_list(:product, 10)
    end

    let!(:order_with_items) { order_with_details(3) }

    it do
      order, items = order_with_items
      should permit(:delivery_address).for(:create, params: { order:, items: }).on(:order)
    end
  end

  describe "POST #create orders without items" do
    # * This test working if you remove the rescue_from in the controller
    # let!(:order_without_items) { order_with_details(3, false) }

    # it "should raise an NotItemsError" do
    #   order, = order_without_items

    #   expect { post :create, params: { order:, items: [] } }.to raise_error(NotItemsError)
    # end

    it "should be rescue from a NotItemsError" do
      should rescue_from(NotItemsError).with(:render_not_items_error)
    end
  end

  describe "PATCH #update" do
    before do
      create_list(:product, 10)
      @order = create(:order)
    end

    let!(:order_with_items) { order_with_details(3) }

    it do
      order, items = order_with_items
      params = {
        id: @order.id,
        order:,
        items:
      }
      should permit(:delivery_address).for(:update, params:).on(:order)
    end
  end
end
