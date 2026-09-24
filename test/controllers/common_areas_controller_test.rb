require "test_helper"

class CommonAreasControllerTest < ActionDispatch::IntegrationTest
  test "should get Reservations" do
    get common_areas_Reservations_url
    assert_response :success
  end

  test "should get MaintenanceRequests" do
    get common_areas_MaintenanceRequests_url
    assert_response :success
  end

  test "should get Visitors" do
    get common_areas_Visitors_url
    assert_response :success
  end

  test "should get Notices" do
    get common_areas_Notices_url
    assert_response :success
  end

  test "should get Payments" do
    get common_areas_Payments_url
    assert_response :success
  end
end
