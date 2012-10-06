require "rspec"
require "spec_helper"
require "factory_girl_rails"

describe "Sync Object Persistence" do

  it "should query modified objects since date" do
    FactoryGirl.create(:post, {:updated_at => 1.days.ago})
    FactoryGirl.create(:post, {:updated_at => 2.days.ago})
    FactoryGirl.create(:post, {:updated_at => 3.days.ago})

    last_sync_time = 2.days.ago - 60 #seconds
    updated_objects = SyncObject.modified_since(last_sync_time)
    updated_objects.should have(2).posts


  end
end