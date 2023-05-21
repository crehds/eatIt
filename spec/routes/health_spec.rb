require "rails_helper"

RSpec.describe "Health", type: :routing do
  it { should route(:get, "/health").to(controller: :health, action: :health) }
end
