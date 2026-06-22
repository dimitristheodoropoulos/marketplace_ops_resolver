require "test_helper"

class OrderExceptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order_exception = order_exceptions(:one)
  end

  test "should get index" do
    get order_exceptions_url
    assert_response :success
  end

  test "should get new" do
    get new_order_exception_url
    assert_response :success
  end

  test "should create order_exception" do
    assert_difference("OrderException.count") do
      post order_exceptions_url, params: { order_exception: { error_message: @order_exception.error_message, merchant_id: @order_exception.merchant_id, order_number: @order_exception.order_number, resolved_at: @order_exception.resolved_at, status: @order_exception.status } }
    end

    assert_redirected_to order_exception_url(OrderException.last)
  end

  test "should show order_exception" do
    get order_exception_url(@order_exception)
    assert_response :success
  end

  test "should get edit" do
    get edit_order_exception_url(@order_exception)
    assert_response :success
  end

  test "should update order_exception" do
    patch order_exception_url(@order_exception), params: { order_exception: { error_message: @order_exception.error_message, merchant_id: @order_exception.merchant_id, order_number: @order_exception.order_number, resolved_at: @order_exception.resolved_at, status: @order_exception.status } }
    assert_redirected_to order_exception_url(@order_exception)
  end

  test "should destroy order_exception" do
    assert_difference("OrderException.count", -1) do
      delete order_exception_url(@order_exception)
    end

    assert_redirected_to order_exceptions_url
  end
end
