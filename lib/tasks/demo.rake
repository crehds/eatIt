namespace :demo do
  desc "Discard what visitors changed in the demo data and load the original demo data again"
  task reset: :environment do
    # Only demo records: the owner's private data is never touched.
    ActiveRecord::Base.transaction do
      Order.where(demo: true).destroy_all
      Product.where(demo: true).destroy_all
      load Rails.root.join("db/seeds.rb")
    end

    puts "Demo data reset: #{Product.where(demo: true).count} products, " \
         "#{Order.where(demo: true).count} orders"
  end
end
