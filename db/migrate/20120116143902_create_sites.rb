class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :url
      t.integer :interval
      t.string :active
      t.string :status
      t.float :delay
      t.string :content
      t.string :watcher
      t.datetime :last_checked

      t.timestamps
    end
  end
end
