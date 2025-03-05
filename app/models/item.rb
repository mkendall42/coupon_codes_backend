class Item < ApplicationRecord
  has_many :invoice_items, dependent: :destroy
  belongs_to :merchant

  validates :name, :description, :unit_price, presence: true

  def self.sorted_by_price
    Item.order(unit_price: :asc)
  end

  def self.find_by_name_string(search_string)
    where("name ILIKE ?", "%#{search_string}%").order(:name).first
  end

  def self.find_by_price_range(min_price, max_price)
    #If either of these not provided, set to default / extreme values to ensure method always works
    min_price ||= 0.0
    max_price ||= Float::INFINITY     #Mwahahaha (and also, I call BS)

    filtered_items = where("unit_price >= ?", min_price)
    filtered_items = filtered_items.where("unit_price <= ?", max_price)

    filtered_items.order(:name).first
  end
end