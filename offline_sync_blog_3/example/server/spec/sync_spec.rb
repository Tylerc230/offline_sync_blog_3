require "rspec"
require "spec_helper"

@shared_guid = "60357A99-9CCD-4D1A-B83A-162E533F915F"
describe "Sync" do

  it "should add new elements from the client" do
    client_modified_entities = [entity_with_guid( "60357A99-9CCD-4D1A-B83A-162E533F915F")]
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

  it "should detect conflicts when they occur" do
    FactoryGirl.create(:post, {:updated_at => 1.day.ago, :guid => @shared_guid})
    client_entities = [entity_with_guid(@shared_guid)]
    response = SyncHelper.sync_entities client_entities, 0
    conflicted_entities = response[SyncHelper::CONFLICTED_ENTITIES_KEY]
    conflicted_entities.should have(1).conflicted_entity
  end

  it "should not detect any conflicts if they are not present" do
    FactoryGirl.create(:post, {:updated_at => 12345, :guid => @shared_guid})
    client_entities = [entity_with_guid(@shared_guid)]
    response = SyncHelper.sync_entities client_entities, 0
    conflicted_entities = response[SyncHelper::CONFLICTED_ENTITIES_KEY]
    conflicted_entities.should have(0).conflicted_entities


  end

end

def entity_with_guid guid
  {:post =>
     {
       :body => "Post Body",
       :guid => guid,
       :is_deleted => "0",
       :updated_at => 12345,
       :title => "post title",

     }}


end