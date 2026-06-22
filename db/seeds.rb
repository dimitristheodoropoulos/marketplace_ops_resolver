# db/seeds.rb
puts "Καθαρισμός παλιών δεδομένων..."
OrderException.destroy_all

puts "Δημιουργία προβληματικών παραγγελιών..."

OrderException.create!([
  {
    order_number: "ORD-99301",
    merchant_id: 1042,
    status: "courier_api_error",
    error_message: "Courier API returned 504 Gateway Timeout. Failed to generate shipping voucher for address: El. Venizelou 45."
  },
  {
    order_number: "ORD-88219",
    merchant_id: 2105,
    status: "stuck_in_processing",
    error_message: "Order stuck in 'processing' for 52 hours. Payment webhook verified, but stock validation failed for item_id: 88472."
  },
  {
    order_number: "ORD-77402",
    merchant_id: 1042,
    status: "courier_api_error",
    error_message: "Validation Error: Postal code 'Unknown' is not recognized by courier 'LastMile_Express'."
  },
  {
    order_number: "ORD-55104",
    merchant_id: 3011,
    status: "stuck_in_processing",
    error_message: "Order stuck. Merchant dashboard timeout during inventory lock call."
  }
])

puts "Έτοιμο! Δημιουργήθηκαν #{OrderException.count} εγγραφές σφαλμάτων."