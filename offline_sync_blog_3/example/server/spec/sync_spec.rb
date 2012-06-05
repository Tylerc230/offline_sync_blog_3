require "rspec"
require "spec_helper"

describe "Sync" do

  it "should add new elements from the client" do
    client_modified_entities = [{:post =>
    {
        :body => "Post Body",
        :guid => "60357A99-9CCD-4D1A-B83A-162E533F915F",
        :is_deleted => "0",
        :updated_at => "1338872968.706092",
        :title => "post title",

    }}
    ]
    SyncHelper.sync_entities client_modified_entities, 0
    SyncObject.all.should have(1).object

  end

  it "should return all modified objects since date" do
    modified_entity = FactoryGirl.create(:post, {:updated_at => 1.day.ago})
    FactoryGirl.create(:post, {:updated_at => 2.day.ago})
    response = SyncHelper.sync_entities [], 1.day.ago - 60
    entities_modified_since_date = response[SyncHelper::MODIFIED_ENTITIES_KEY]

    entities_modified_since_date.should have(1).modified_entity
    entities_modified_since_date.last.should eq(modified_entity)

  end
end