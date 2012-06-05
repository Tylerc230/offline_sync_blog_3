module SyncHelper
  MODIFIED_ENTITIES_KEY = :modified_entities
  LAST_SYNC_TIME_KEY = :updated_at
  GUID_KEY = :guid
  CLASS_NAME_KEY = :classname
  def self.sync_entities client_modified_entities, client_last_sync
    self.sync_client_modifications client_modified_entities
    response = {}
    server_modified_entities = SyncObject.modified_since client_last_sync
    response[MODIFIED_ENTITIES_KEY] = server_modified_entities
    response
  end

  def self.sync_client_modifications client_modified_entities
    client_modified_entities.each do |entity|
      klass = entity.keys.last
      attributes = entity[klass]
      guid = attributes[GUID_KEY]
      updated_record = SyncObject.find_by_guid guid
      if updated_record.nil?
        updated_record = klass.to_s.capitalize.constantize.new
      end
      updated_record.update_attributes attributes
      updated_record.save
    end
  end

end
