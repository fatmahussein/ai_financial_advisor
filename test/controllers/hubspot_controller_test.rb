require 'test_helper'

class HubspotControllerTest < ActionDispatch::IntegrationTest
  test 'should get connect' do
    get hubspot_connect_url
    assert_response :success
  end

  test 'should get callback' do
    get hubspot_callback_url
    assert_response :success
  end
end
