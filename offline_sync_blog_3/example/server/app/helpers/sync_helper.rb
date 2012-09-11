module SyncHelper
  MODIFIED_ENTITIES_KEY = :modified_entities
  CONFLICTED_ENTITIES_KEY = :conflicted_entities
  LAST_SYNC_TIME_KEY = :last_sync_time
  GUID_KEY = :guid
  CLASS_NAME_KEY = :classname

  def self.sync_entities client_modified_entities, client_last_sync
    conflicts = self.sync_client_modifications client_modified_entities
    response = {}
    response[MODIFIED_ENTITIES_KEY] = SyncObject.modified_since( client_last_sync).all
    response[CONFLICTED_ENTITIES_KEY] = conflicts
    response
  end
  def self.sync_client_modifications client_modified_entities
    conflicts = []
    client_modified_entities.each do |entity|
      klass = entity.keys.last
      attributes = entity[klass]
      client_record = klass.to_s.capitalize.constantize.new attributes
      exists = SyncObject.exists? :guid => client_record.guid
      if exists
        server_record = SyncObject.find_by_guid client_record.guid
        conflicted = client_record.updated_at != server_record.updated_at
        if conflicted
          conflicts << client_record
        else
          server_record.update_attributes attributes
          server_record.save
        end
      else
        client_record.save
      end
    end
    conflicts
  end
end
