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
      guid = attributes[GUID_KEY]
      client_last_updated = attributes[LAST_SYNC_TIME_KEY]
      updated_record = SyncObject.find_by_guid guid
      if updated_record.nil?
        updated_record = klass.to_s.capitalize.constantize.new attributes
      else
        conflict_detected = self.detect_conflict client_last_updated, updated_record
        if conflict_detected
          conflicts << updated_record
        else
          updated_record.update_attributes attributes
        end
      end
      updated_record.save
    end
    conflicts
  end

  def self.detect_conflict client_last_updated_at, server_entity
    client_last_updated_at != server_entity.updated_at
  end

  def self.modifications_since_date client_last_sync
    return SyncObject.modified_since client_last_sync
  end

end
