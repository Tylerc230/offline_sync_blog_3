require 'test_helper'

class SyncControllerTest < ActionController::TestCase
  test "should get sync" do
    get :sync
    assert_response :success
  end

end
