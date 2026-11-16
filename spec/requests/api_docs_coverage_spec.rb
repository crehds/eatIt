require "rails_helper"

RSpec.describe "OpenAPI document coverage" do
  it "documents every application route and nothing else" do
    document = YAML.safe_load_file(Rails.root.join("swagger/v1/swagger.yaml"))
    documented = document["paths"].flat_map do |path, operations|
      (operations.keys - ["parameters"]).map { |verb| "#{verb.upcase} #{path}" }
    end

    routed = Rails.application.routes.routes.filter_map do |route|
      next if route.verb.blank? # engine mounts

      path = route.path.spec.to_s.delete_suffix("(.:format)").gsub(/:(\w+)/, '{\1}')
      next if path == "/" || path.start_with?("/rails/") # root redirect and framework routes

      # PUT is documented in the PATCH operation's description.
      "#{route.verb} #{path}".sub(/\APUT /, "PATCH ")
    end.uniq

    expect(routed - documented).to be_empty
    expect(documented - routed).to be_empty
  end
end
