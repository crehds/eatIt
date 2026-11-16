class AddDemoToProductsAndOrders < ActiveRecord::Migration[8.1]
  def change
    # Every existing record is demo data, so the default classifies them correctly.
    add_column :products, :demo, :boolean, default: true, null: false
    add_column :orders, :demo, :boolean, default: true, null: false

    # Names stay unique within each space; a global index would reveal owner product
    # names to visitors through validation errors.
    remove_index :products, :name, unique: true
    add_index :products, %i[name demo], unique: true
  end
end
