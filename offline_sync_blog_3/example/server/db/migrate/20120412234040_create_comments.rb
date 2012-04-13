class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :comment

    end
    create_citier_view(Comment)
  end

  def self.down
    drop_citier_view(Comment)
    drop_table :comments
  end
end
