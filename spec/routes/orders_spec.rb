require "rails_helper"

RSpec.describe "Orders", type: :routing do
  it { should route(:get, "/orders").to(controller: :orders, action: :index) }
  it { should route(:get, "/orders/1").to(controller: :orders, action: :show, id: 1) }
  it { should route(:post, "/orders").to(controller: :orders, action: :create) }
  it { should route(:put, "/orders/1").to(controller: :orders, action: :update, id: 1) }
  it { should route(:delete, "/orders/1").to(controller: :orders, action: :destroy, id: 1) }
end
