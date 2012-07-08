class CreateTimeLogs < ActiveRecord::Migration
  def change
    create_table :time_logs do |t|
      t.references :site
      t.datetime :checked
      t.string :status
      t.float :delay
      t.string :watcher

      t.timestamps
    end
    add_index :time_logs, :site_id
  end
end
