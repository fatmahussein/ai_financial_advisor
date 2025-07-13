require "test_helper"

class ChatsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get chats_index_url
    assert_response :success
  end

  test "should get history" do
    get chats_history_url
    assert_response :success
  end

  test "should get new" do
    get chats_new_url
    assert_response :success
  end

  test "should get create_message" do
    get chats_create_message_url
    assert_response :success
  end
end
