require "rspec"
require "spec_helper"

describe "Sync" do

  it "should add new elements from the client" do
    client_modified_entities = [entity_with_guid( "60357A99-9CCD-4D1A-B83A-162E533F915F")]
    SyncHelper.sync_entities client_modified_entities, 0
    SyncObject.all.should have(1).object

  end

  it "should return all modified objects since date" do
    modified_entity = Factory(:post, {:updated_at => 1.day.ago})
    Factory(:post, {:updated_at => 2.day.ago})
    response = SyncHelper.sync_entities [], 1.day.ago - 60
    entities_modified_since_date = response[SyncHelper::MODIFIED_ENTITIES_KEY]

    entities_modified_since_date.should have(1).modified_entity
    entities_modified_since_date.last.should eq(modified_entity)

  end

  it "should detect conflicts when they occur" do
    shared_guid = "60357A99-9CCD-4D1A-B83A-162E533F915F",
    Factory(:post, {:updated_at => 1.day.ago, :guid => shared_guid})
    client_entities = [entity_with_guid(shared_guid)]
    response = SyncHelper.sync_entities client_entities, 0
    conflicted_entities = response[SyncHelper::CONFLICTED_ENTITIES_KEY]
    conflicted_entities.should have(1).conflicted_entity
  end

end

def entity_with_guid guid
  {:post =>
     {
       :body => "Post Body",
       :guid => guid,
       :is_deleted => "0",
       :updated_at => "1338872968.706092",
       :title => "post title",

     }}


end