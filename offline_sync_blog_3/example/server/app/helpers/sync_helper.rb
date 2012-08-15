module SyncHelper
  MODIFIED_ENTITIES_KEY = :modified_entities
  CONFLICTED_ENTITIES_KEY = :conflicted_entities
  LAST_SYNC_TIME_KEY = :updated_at
  GUID_KEY = :guid
  CLASS_NAME_KEY = :classname

  def self.sync_entities client_modified_entities, client_last_sync
    conflicts = self.sync_client_modifications client_modified_entities
    response = {}
    response[MODIFIED_ENTITIES_KEY] = self.modifications_since_date client_last_sync
    response[CONFLICTED_ENTITIES_KEY] = conflicts
    response
  end

  def self.sync_client_modifications client_modified_entities
    conflicts = []
    client_modified_entities.each do |entity|
      klass = entity.keys.last
      attributes = entity[klass]
      server_record = klass.to_s.capitalize.constantize.new attributes
      exists = SyncObject.exists? :guid => server_record.guid
      if exists
        server_record = SyncObject.find_by_guid server_record.guid
        client_modification_timestamp = server_record.updated_at
        conflicted = self.conflicted? client_modification_timestamp, server_record
        if conflicted
          conflicts << server_record
        end
      end
      server_record.save
    end
    conflicts
  end

  def self.conflicted? client_modification_timestamp, server_entity
    client_modification_timestamp != server_entity.updated_at
  end

  def self.modifications_since_date client_last_sync
    return SyncObject.modified_since client_last_sync
  end

end
