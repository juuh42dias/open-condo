require "test_helper"

class MaintenanceRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get maintenance_requests_index_url
    assert_response :success
  end

  test "should get create" do
    get maintenance_requests_create_url
    assert_response :success
  end

  test "should get show" do
    get maintenance_requests_show_url
    assert_response :success
  end

  test "should get update" do
    get maintenance_requests_update_url
    assert_response :success
  end
end
