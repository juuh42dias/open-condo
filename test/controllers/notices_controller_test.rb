require "test_helper"

class NoticesControllerTest < ActionDispatch::IntegrationTest
  test "should get Payments" do
    get notices_Payments_url
    assert_response :success
  end
end
