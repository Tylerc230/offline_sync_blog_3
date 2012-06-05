module SyncHelper
  MODIFIED_ENTITIES_KEY = 'modifiedEntities'
  LAST_SYNC_TIME_KEY = 'lastSyncTime'
  def self.sync_entities client_modified_entities, client_last_sync
    response = {}
    server_modified_entities = SyncObject.modified_since client_last_sync
    response[MODIFIED_ENTITIES_KEY] = server_modified_entities
    response
  end

end
