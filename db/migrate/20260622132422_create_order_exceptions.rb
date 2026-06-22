class CreateOrderExceptions < ActiveRecord::Migration[8.1]
  def change
    create_table :order_exceptions do |t|
      t.string :order_number
      t.integer :merchant_id
      t.string :status
      t.text :error_message
      t.datetime :resolved_at

      t.timestamps
    end
  end
end
