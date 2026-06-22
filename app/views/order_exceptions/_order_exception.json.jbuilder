json.extract! order_exception, :id, :order_number, :merchant_id, :status, :error_message, :resolved_at, :created_at, :updated_at
json.url order_exception_url(order_exception, format: :json)
