class AddDowncountToSites < ActiveRecord::Migration
  def change
    add_column :sites, :down_count, :integer
  end
end
