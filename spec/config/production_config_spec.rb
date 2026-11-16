require "rails_helper"

RSpec.describe "config/environments/production.rb" do
  let(:source) { Rails.root.join("config/environments/production.rb").read }

  it "keeps force_ssl and assume_ssl off, as before the upgrade" do
    expect(source).not_to match(/^\s*config\.(force_ssl|assume_ssl)\s*=\s*true/)
  end
end
