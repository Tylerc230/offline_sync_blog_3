class SyncController < ApplicationController
  def sync
    client_modified_entities = params[SyncHelper::MODIFIED_ENTITIES_KEY]
    client_last_sync = params[SyncHelper::LAST_SYNC_TIME_KEY]
    response = SyncHelper.sync_entities client_modified_entities, client_last_sync
    respond_to do |format|
          format.json { render :json => response}
        end
  end

end
