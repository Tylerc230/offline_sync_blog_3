class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :body
      t.string :title

    end
    create_citier_view(Post)
  end

  def self.down
    drop_citier_view(Post)
    drop_table :posts
  end
end
