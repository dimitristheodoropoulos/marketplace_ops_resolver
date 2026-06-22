class AddAiFieldsToOrderExceptions < ActiveRecord::Migration[8.1]
  def change
    add_column :order_exceptions, :ai_category, :string
    add_column :order_exceptions, :ai_suggested_action, :text
  end
end
