require 'test_helper'

class TimeLogsControllerTest < ActionController::TestCase
  setup do
    @time_log = time_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:time_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create time_log" do
    assert_difference('TimeLog.count') do
      post :create, time_log: @time_log.attributes
    end

    assert_redirected_to time_log_path(assigns(:time_log))
  end

  test "should show time_log" do
    get :show, id: @time_log.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @time_log.to_param
    assert_response :success
  end

  test "should update time_log" do
    put :update, id: @time_log.to_param, time_log: @time_log.attributes
    assert_redirected_to time_log_path(assigns(:time_log))
  end

  test "should destroy time_log" do
    assert_difference('TimeLog.count', -1) do
      delete :destroy, id: @time_log.to_param
    end

    assert_redirected_to time_logs_path
  end
end
