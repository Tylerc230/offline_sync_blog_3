# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120412234040) do

  create_table "comments", :force => true do |t|
    t.string "comment"
  end

  create_table "posts", :force => true do |t|
    t.string "body"
    t.string "title"
  end

  create_table "sync_objects", :force => true do |t|
    t.string   "type"
    t.boolean  "is_deleted"
    t.string   "guid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_view "view_comments", "SELECT sync_objects.id, type,is_deleted,guid,created_at,updated_at,comment FROM sync_objects, comments WHERE sync_objects.id = comments.id", :force => true do |v|
    v.column :id
    v.column :type
    v.column :is_deleted
    v.column :guid
    v.column :created_at
    v.column :updated_at
    v.column :comment
  end

  create_view "view_posts", "SELECT sync_objects.id, type,is_deleted,guid,created_at,updated_at,body,title FROM sync_objects, posts WHERE sync_objects.id = posts.id", :force => true do |v|
    v.column :id
    v.column :type
    v.column :is_deleted
    v.column :guid
    v.column :created_at
    v.column :updated_at
    v.column :body
    v.column :title
  end

end
