class Item < ApplicationRecord
  has_many :invoice_items, dependent: :destroy
  belongs_to :merchant

  def self.sorted_by_price
    Item.order(unit_price: :asc)
  end
end