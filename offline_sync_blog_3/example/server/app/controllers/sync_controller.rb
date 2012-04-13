class SyncController < ApplicationController
  def sync
    modifiedEntities = params[:modifiedEntities]
    response = {}
    respond_to do |format|
          format.json { render :json => response}
        end
  end

end
