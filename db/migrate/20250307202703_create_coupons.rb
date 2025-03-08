class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :name
      t.string :code
      t.boolean :status
      t.float :discount_value
      t.float :discount_percentage
      t.references :merchant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
