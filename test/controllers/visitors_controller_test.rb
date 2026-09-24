require "test_helper"

class VisitorsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get visitors_index_url
    assert_response :success
  end

  test "should get create" do
    get visitors_create_url
    assert_response :success
  end

  test "should get show" do
    get visitors_show_url
    assert_response :success
  end
end
