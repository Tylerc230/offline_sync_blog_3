class SyncController < ApplicationController
  def sync
    client_modified_entities = params[:modifiedEntities]
    client_last_sync = params[:lastSyncTime]
    SyncHelper.sy
    response = {}
    respond_to do |format|
          format.json { render :json => response}
        end
  end

end
