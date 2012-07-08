class AddNextCheckToSites < ActiveRecord::Migration
  def change
    add_column :sites, :next_check, :datetime
  end
end
