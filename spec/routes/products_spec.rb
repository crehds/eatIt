require "rails_helper"

RSpec.describe "Products", type: :routing do
  it { should route(:get, "/products").to(controller: :products, action: :index) }
  it { should route(:get, "/products/1").to(controller: :products, action: :show, id: 1) }
  it { should route(:post, "/products").to(controller: :products, action: :create) }
  it { should route(:put, "/products/1").to(controller: :products, action: :update, id: 1) }
  it { should route(:delete, "/products/1").to(controller: :products, action: :destroy, id: 1) }
end
