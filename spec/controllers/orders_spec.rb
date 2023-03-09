require "rails_helper"

RSpec.describe OrdersController, type: :controller do
  describe "GET #index" do
    subject { get :index }

    it { should have_http_status(:ok) }
  end
end
