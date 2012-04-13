class CreateSyncObjects < ActiveRecord::Migration
  def self.up
    create_table :sync_objects do |t|
      t.string :type
      t.boolean :is_deleted
      t.string :guid

      t.timestamps
    end
  end

  def self.down
    drop_table :sync_objects
  end
end
