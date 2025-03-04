class Item < ApplicationRecord
  has_many :invoice_items, dependent: :destroy
  belongs_to :merchant

  validates :name, :description, :unit_price, presence: true

  def self.sorted_by_price
    Item.order(unit_price: :asc)
  end
end