require "rails_helper"

RSpec.describe "config/environments/production.rb" do
  let(:source) { Rails.root.join("config/environments/production.rb").read }

  # Railway's edge terminates TLS and always sends X-Forwarded-Proto: https. With assume_ssl,
  # its plain-HTTP health checks on /health are not redirected by force_ssl.
  it "enables assume_ssl and force_ssl for Railway's TLS-terminating proxy" do
    expect(source).to match(/^\s*config\.assume_ssl\s*=\s*true/)
    expect(source).to match(/^\s*config\.force_ssl\s*=\s*true/)
  end

  it "silences the logs of the /health check" do
    expect(source).to match(%r{^\s*config\.silence_healthcheck_path\s*=\s*"/health"})
  end
end
