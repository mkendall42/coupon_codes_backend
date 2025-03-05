class Merchant < ApplicationRecord
  has_many :invoices, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :customers, through: :invoices

  def self.sorted_by_age
    order(created_at: :desc)
  end

  def self.has_returned_items
    joins(:invoices).where( invoices: { status: "returned" })
  end

  def item_count
    items.count
  end

  def self.find_by_name_string(search_string)
    where("name ILIKE ?", "%#{search_string}%").order(:name)
  end
end